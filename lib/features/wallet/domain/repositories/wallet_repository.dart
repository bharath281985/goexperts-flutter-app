import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Result<WalletSummary>> getSummary();
  Future<Result<Paginated<WalletTransaction>>> getTransactions(
    QueryParams params,
  );
  Future<Result<WalletTransaction>> getTransaction(String id);
  Future<Result<Paginated<Invoice>>> getInvoices(QueryParams params);
  Future<Result<Invoice>> getInvoice(String id);
  Future<Result<String>> requestWithdrawal({
    required double amount,
    required String method,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? upiDetails,
  });
  Future<Result<String>> addMoney({
    required double amount,
    required String gateway,
    required String currency,
    required String purpose,
  });
}
