import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/company.dart';

abstract class CompanyRepository {
  Future<Result<Paginated<Company>>> getCompanies(QueryParams params);
  Future<Result<Company>> getCompany(String id);
  Future<Result<bool>> toggleFollow(String id);
  Future<Result<Company>> getClientProfile();
  Future<Result<Company>> updateClientProfile(
    Map<String, dynamic> data, {
    String? logoPath,
  });
  Future<Result<String>> uploadClientLogo(String filePath);
  Future<Result<String>> uploadClientDocument(String filePath);
}
