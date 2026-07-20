import '../../../../app/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  Future<UserRole?> _role() async => await _tokenRoleHelper?.resolve();

  @override
  Future<Result<WalletSummary>> getSummary() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = role == UserRole.freelancer
        ? ApiEndpoints.freelancerWallet
        : role == UserRole.client
        ? ApiEndpoints.clientWallet
        : role == UserRole.founder
        ? ApiEndpoints.founderWallet
        : role == UserRole.investor
        ? ApiEndpoints.investorWallet
        : ApiEndpoints.wallet;

    final result = await _api.get<WalletSummary>(
      path,
      parser: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final balance = (map['balance'] as num?)?.toDouble() ?? 0;
        return WalletSummary(
          available: (map['available'] as num?)?.toDouble() ?? balance,
          pending: (map['pending'] as num?)?.toDouble() ?? 0,
          lifetime: (map['lifetime'] as num?)?.toDouble() ?? balance,
          escrow: (map['escrow'] as num?)?.toDouble() ?? 0,
        );
      },
    );
    return result;
  }

  @override
  Future<Result<Paginated<WalletTransaction>>> getTransactions(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = role == UserRole.freelancer
        ? ApiEndpoints.freelancerWalletTransactions
        : role == UserRole.client
        ? ApiEndpoints.clientWalletTransactions
        : role == UserRole.founder
        ? '${ApiEndpoints.founderWallet}/transactions'
        : role == UserRole.investor
        ? ApiEndpoints.investorWalletTransactions
        : ApiEndpoints.walletTransactions;

    final result = await _api.getEnvelope<Paginated<WalletTransaction>>(
      path,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _transactionFromJson,
        fallbackPage: params.page,
      ),
    );
    return result;
  }

  @override
  Future<Result<Paginated<Invoice>>> getInvoices(QueryParams params) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = role == UserRole.freelancer
        ? ApiEndpoints.freelancerWalletPaymentHistory
        : role == UserRole.client
        ? ApiEndpoints.clientInvoices
        : role == UserRole.founder
        ? ApiEndpoints.founderInvoices
        : ApiEndpoints.invoices;

    final result = await _api.getEnvelope<Paginated<Invoice>>(
      path,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _invoiceFromJson,
        fallbackPage: params.page,
      ),
    );
    return result;
  }

  @override
  Future<Result<WalletTransaction>> getTransaction(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return const Err(
      NotFoundFailure('Transaction detail API pending role prefix.'),
    );
  }

  @override
  Future<Result<Invoice>> getInvoice(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    if (role == UserRole.freelancer) {
      // Freelancer doesn't have a dedicated `GET /invoices/:id` in the matrix.
      final listRes = await getInvoices(
        const QueryParams(page: 1, pageSize: 100),
      );
      return listRes.fold((failure) => Err(failure), (page) {
        final match = page.items.where((i) => i.id == id);
        if (match.isEmpty) return const Err(NotFoundFailure());
        return Success(match.first);
      });
    }
    final result = await _api.get<Invoice>(
      '${ApiEndpoints.invoices}/$id',
      parser: (data) =>
          _invoiceFromJson(Map<String, dynamic>.from(data as Map)),
    );
    return result;
  }

  @override
  Future<Result<String>> requestWithdrawal({
    required double amount,
    required String method,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? upiDetails,
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.freelancer
        ? ApiEndpoints.freelancerWalletWithdraw
        : role == UserRole.founder
        ? ApiEndpoints.founderWalletWithdraw
        : role == UserRole.investor
        ? ApiEndpoints.investorWalletWithdraw
        : ApiEndpoints.freelancerWalletWithdraw;

    return _api.postEnvelopeAcceptingHttpSuccess<String>(
      path,
      body: {
        'amount': amount,
        'method': method,
        if (method == 'bank' && bankDetails != null) 'bankDetails': bankDetails,
        if (method == 'upi' && upiDetails != null) 'upiDetails': upiDetails,
      },
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Withdrawal requested',
    );
  }

  @override
  Future<Result<String>> addMoney({
    required double amount,
    required String gateway,
    required String currency,
    required String purpose,
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postEnvelopeAcceptingHttpSuccess<String>(
      ApiEndpoints.clientPaymentsInitiate,
      body: {
        'amount': amount,
        'gateway': gateway,
        'currency': currency,
        'purpose': purpose,
      },
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Payment initiated successfully',
    );
  }

  static WalletTransaction _transactionFromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      title:
          json['title'] as String? ??
          json['description'] as String? ??
          json['reason'] as String? ??
          'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: _parseType(json['type'] as String?),
      date:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      reference: json['reference'] as String? ?? '',
      status: _capitalize(
        json['status'] as String? ??
            json['transactionStatus'] as String? ??
            json['transaction_status'] as String? ??
            json['paymentStatus'] as String? ??
            'Completed',
      ),
      direction: json['direction'] as String? ?? '',
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Invoice _invoiceFromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      number:
          json['number'] as String? ?? json['invoiceNumber'] as String? ?? '',
      party: json['party'] as String? ?? json['clientName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      issuedAt:
          DateTime.tryParse(json['issuedAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
    );
  }

  static TransactionType _parseType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'escrow':
        return TransactionType.escrow;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.credit;
    }
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
