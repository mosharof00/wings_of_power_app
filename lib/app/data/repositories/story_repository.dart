import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/stories.dart';
import '../models/story_models.dart';

abstract class IStoryRepository {
  Future<StoryListResponse> getStories({
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 20,
  });

  Future<StoryDetailModel> getStoryDetail(String id);
}

class StoryRepository implements IStoryRepository {
  final ApiClient _client;

  StoryRepository(this._client);

  @override
  Future<StoryListResponse> getStories({
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    if (AppConfig.useMocks) {
      return StoriesMock.getStories(
        category: category,
        ageGroup: ageGroup,
        search: search,
        page: page,
        perPage: perPage,
      );
    }
    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.stories,
        queryParameters: {
          if (category != null &&
              category.isNotEmpty &&
              category.toLowerCase() != 'all' &&
              category.toLowerCase() != 'all category')
            'category': category,
          if (ageGroup != null &&
              ageGroup.isNotEmpty &&
              ageGroup.toLowerCase() != 'all' &&
              ageGroup.toLowerCase() != 'all age group')
            'ageGroup': ageGroup,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'perPage': perPage,
        },
      ),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return StoryListResponse.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Stories',
    );
  }

  @override
  Future<StoryDetailModel> getStoryDetail(String id) async {
    if (AppConfig.useMocks) {
      return StoriesMock.getStoryDetail(id);
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.storyDetail(id)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return StoryDetailModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Story Detail',
    );
  }
}
