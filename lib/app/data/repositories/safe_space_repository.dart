import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/safe_space.dart';
import '../models/safe_space_models.dart';

abstract class ISafeSpaceRepository {
  Future<SafeSpaceReportsResponseModel> getReports({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<SafeSpaceReportModel> getReportDetail(String id);

  Future<SafeSpaceReportModel> createReport(CreateSafeSpaceReportRequest request);
}

class SafeSpaceRepository implements ISafeSpaceRepository {
  final ApiClient _client;

  SafeSpaceRepository(this._client);

  @override
  Future<SafeSpaceReportsResponseModel> getReports({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    if (AppConfig.useMocks) {
      return SafeSpaceMock.getReports(
        status: status,
        page: page,
        perPage: perPage,
      );
    }

    final query = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };
    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
      query['status'] = status.toUpperCase();
    }

    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.safeSpaceReports,
        queryParameters: query,
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return SafeSpaceReportsResponseModel.fromJson(map);
      },
      'Get Safe Space Reports',
    );
  }

  @override
  Future<SafeSpaceReportModel> getReportDetail(String id) async {
    if (AppConfig.useMocks) {
      return SafeSpaceMock.getReportById(id);
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.safeSpaceReportDetail(id)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return SafeSpaceReportModel.fromJson(map);
      },
      'Get Safe Space Report Detail',
    );
  }

  @override
  Future<SafeSpaceReportModel> createReport(
    CreateSafeSpaceReportRequest request,
  ) async {
    if (AppConfig.useMocks) {
      return SafeSpaceMock.createReport(request);
    }

    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.safeSpaceReports,
        data: request.toJson(),
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        return SafeSpaceReportModel.fromJson(map);
      },
      'Create Safe Space Report',
    );
  }
}
