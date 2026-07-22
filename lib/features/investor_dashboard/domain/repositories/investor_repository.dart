import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/investor.dart';

abstract class InvestorRepository {
  Future<Result<Paginated<Investor>>> getInvestors(QueryParams params);
  Future<Result<Investor>> getInvestor(String id);
  Future<Result<Paginated<Deal>>> getDeals(QueryParams params);
  Future<Result<Paginated<PortfolioItem>>> getPortfolio(QueryParams params);
  Future<Result<bool>> toggleFollow(String id);
  Future<Result<bool>> toggleSave(String id);
}
