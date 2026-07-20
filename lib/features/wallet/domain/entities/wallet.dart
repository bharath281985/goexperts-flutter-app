import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit, withdrawal, escrow, refund }

/// A wallet transaction row.
class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.reference = '',
    this.status = 'Completed',
    this.direction = '',
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String reference;
  final String status;
  final String direction;

  bool get isCredit =>
      type == TransactionType.credit || type == TransactionType.refund;

  @override
  List<Object?> get props => [id, amount, type, status, direction];
}

/// Aggregate wallet balances for the wallet dashboard.
class WalletSummary extends Equatable {
  const WalletSummary({
    required this.available,
    required this.pending,
    required this.lifetime,
    this.escrow = 0,
  });

  final double available;
  final double pending;
  final double lifetime;
  final double escrow;

  @override
  List<Object?> get props => [available, pending, lifetime, escrow];
}

/// An invoice document.
class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.number,
    required this.party,
    required this.amount,
    required this.issuedAt,
    required this.status,
  });

  final String id;
  final String number;
  final String party;
  final double amount;
  final DateTime issuedAt;
  final String status;

  @override
  List<Object?> get props => [id, status];
}
