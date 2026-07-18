import 'dart:convert';

import 'package:easebuzz_flutter/easebuzz_flutter.dart';
import 'package:flutter/services.dart';

import '../errors/failures.dart';
import '../network/api_client_helper.dart';
import '../network/api_endpoints.dart';
import '../utils/result.dart';

class PaymentInitiateResult {
  const PaymentInitiateResult({
    required this.paymentId,
    required this.gateway,
    required this.paymentUrl,
    required this.orderId,
    this.gatewayPayload = const {},
  });

  final String paymentId;
  final String gateway;
  final String paymentUrl;
  final String orderId;
  final Map<String, dynamic> gatewayPayload;

  String? get accessKey =>
      gatewayPayload['accessKey']?.toString() ??
      gatewayPayload['access_key']?.toString();

  /// Easebuzz SDK expects `test` or `production`.
  String get payMode {
    final raw = gatewayPayload['payMode']?.toString().toLowerCase();
    if (raw == 'production' || raw == 'live') return 'production';
    return 'test';
  }
}

class EasebuzzCheckoutResult {
  const EasebuzzCheckoutResult({
    required this.success,
    required this.status,
    this.raw = const {},
    this.message,
  });

  final bool success;
  final String status;
  final Map<String, dynamic> raw;
  final String? message;

  bool get cancelled =>
      status == 'user_cancelled' ||
      status == 'payment_user_cancelled' ||
      status == 'cancelled';
}

/// Backend initiates payment (secrets stay server-side).
/// Flutter opens Easebuzz SDK with the returned access key only.
class PaymentCheckoutService {
  PaymentCheckoutService(this._api);

  final ApiClientHelper _api;
  final EasebuzzFlutter _easebuzz = EasebuzzFlutter();

  Future<Result<PaymentInitiateResult>> initiate({
    required String gateway,
    required String purpose,
    required double amount,
    String currency = 'INR',
    String? planId,
    Map<String, dynamic>? metadata,
    String? endpoint,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      endpoint ?? ApiEndpoints.paymentsInitiate,
      body: {
        'gateway': gateway,
        'purpose': purpose,
        'amount': amount,
        'currency': currency,
        if (planId != null) 'planId': planId,
        if (metadata != null) 'metadata': metadata,
      },
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );

    return res.fold(
      Err.new,
      (json) => Success(
        PaymentInitiateResult(
          paymentId: json['paymentId']?.toString() ?? '',
          gateway: json['gateway']?.toString() ?? gateway,
          paymentUrl: json['paymentUrl']?.toString() ?? '',
          orderId: json['orderId']?.toString() ?? '',
          gatewayPayload: json['gatewayPayload'] is Map
              ? Map<String, dynamic>.from(json['gatewayPayload'] as Map)
              : const {},
        ),
      ),
    );
  }

  /// Opens Easebuzz native checkout inside the app.
  Future<Result<EasebuzzCheckoutResult>> payWithEasebuzzSdk(
    PaymentInitiateResult payment,
  ) async {
    final accessKey = payment.accessKey;
    if (accessKey == null || accessKey.isEmpty) {
      return const Err(
        ValidationFailure('Payment access key missing. Please try again.'),
      );
    }

    try {
      final response = await _easebuzz.payWithEasebuzz(
        accessKey,
        payment.payMode,
      );
      final parsed = _parseEasebuzzResponse(response);
      if (parsed.cancelled) {
        return Err(ValidationFailure(parsed.message ?? 'Payment cancelled'));
      }
      if (!parsed.success) {
        return Err(
          ServerFailure(parsed.message ?? 'Payment failed. Please try again.'),
        );
      }
      return Success(parsed);
    } on PlatformException catch (e) {
      return Err(
        ServerFailure(e.message ?? 'Payment failed. Please try again.'),
      );
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  /// Initiate + open Easebuzz SDK in one step.
  Future<
    Result<({PaymentInitiateResult payment, EasebuzzCheckoutResult checkout})>
  >
  checkoutWithEasebuzz({
    required String purpose,
    required double amount,
    String currency = 'INR',
    String? planId,
    Map<String, dynamic>? metadata,
    String? endpoint,
  }) async {
    final initiateResult = await initiate(
      gateway: 'easebuzz',
      purpose: purpose,
      amount: amount,
      currency: currency,
      planId: planId,
      metadata: metadata,
      endpoint: endpoint,
    );
    if (initiateResult.isFailure) {
      return Err(initiateResult.failureOrNull!);
    }

    final payment = initiateResult.valueOrNull!;
    final checkoutResult = await payWithEasebuzzSdk(payment);
    if (checkoutResult.isFailure) {
      return Err(checkoutResult.failureOrNull!);
    }

    return Success((payment: payment, checkout: checkoutResult.valueOrNull!));
  }

  Future<Result<Map<String, dynamic>>> verify({
    required String paymentId,
    required String gateway,
    String? purpose,
    String? planId,
    Map<String, dynamic>? verification,
    String? endpoint,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      endpoint ?? ApiEndpoints.paymentsVerify,
      body: {
        'paymentId': paymentId,
        'gateway': gateway,
        if (purpose != null) 'purpose': purpose,
        if (planId != null) 'planId': planId,
        ...?verification,
      },
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );
    return res;
  }

  EasebuzzCheckoutResult _parseEasebuzzResponse(dynamic response) {
    final map = _toMap(response);
    final status =
        (map['result'] ?? map['status'] ?? map['payment_status'] ?? '')
            .toString()
            .toLowerCase();

    final paymentResponse = map['payment_response'];
    final nested = paymentResponse is Map
        ? Map<String, dynamic>.from(paymentResponse)
        : paymentResponse is String
        ? _toMap(paymentResponse)
        : <String, dynamic>{};

    final nestedStatus = (nested['status'] ?? nested['txn_status'] ?? '')
        .toString()
        .toLowerCase();

    final success =
        status.contains('success') ||
        nestedStatus == 'success' ||
        status == 'payment_success';

    final cancelled =
        status.contains('cancel') ||
        status == 'user_cancelled' ||
        status == 'payment_user_cancelled';

    final message =
        map['error_Message']?.toString() ??
        map['error']?.toString() ??
        nested['error']?.toString() ??
        (cancelled
            ? 'Payment cancelled'
            : success
            ? 'Payment successful'
            : 'Payment failed');

    return EasebuzzCheckoutResult(
      success: success && !cancelled,
      status: cancelled
          ? 'user_cancelled'
          : success
          ? 'success'
          : (status.isEmpty ? 'failed' : status),
      raw: {...map, if (nested.isNotEmpty) 'payment_response': nested},
      message: message,
    );
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return {};
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return {'result': trimmed};
      }
      return {'result': trimmed};
    }
    return {'result': value.toString()};
  }
}
