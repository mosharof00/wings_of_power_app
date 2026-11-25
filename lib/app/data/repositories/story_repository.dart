import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/network/api_client.dart';
import 'package:wings_of_power_app/app/core/network/api_endpoints.dart';
import '../mocks/chapter_pages.dart';
import '../mocks/stories.dart';
import '../models/story_models.dart';

abstract class IStoryRepository {
  Future<List<StoryThemeModel>> getThemes();

  Future<StoryListResponse> getStories({
    String? themeId,
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 50,
  });

  Future<StoryDetailModel> getStoryDetail(String id);

  Future<ChapterDetailModel> getChapterDetail({
    required String storyId,
    required String chapterId,
  });

  Future<bool> updateReadingProgress({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required int percent,
    String mode = 'read',
  });

  Future<bool> markPageRead({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required String mode,
    int? dwellSeconds,
    int? listenPercent,
  });

  Future<bool> completeChapter({
    required String storyId,
    required String chapterId,
  });
}

class StoryRepository implements IStoryRepository {
  final ApiClient _client;

  StoryRepository(this._client);

  @override
  Future<List<StoryThemeModel>> getThemes() async {
    if (AppConfig.useMocks) {
      return StoriesMock.getThemes();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.themes),
      (dynamic data) {
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : const []);
        return list
            .map((e) =>
                StoryThemeModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      },
      'Get Themes',
    );
  }

  @override
  Future<StoryListResponse> getStories({
    String? themeId,
    String? category,
    String? ageGroup,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    if (AppConfig.useMocks) {
      return StoriesMock.getStories(
        themeId: themeId,
        category: category,
        ageGroup: ageGroup,
        search: search,
        page: page,
        perPage: perPage,
      );
    }

    final query = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };
    if (themeId != null && themeId.isNotEmpty) {
      query['themeId'] = themeId;
    } else if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all' &&
        category.toLowerCase() != 'all category') {
      query['category'] = category;
    }
    if (ageGroup != null &&
        ageGroup.isNotEmpty &&
        ageGroup.toLowerCase() != 'all' &&
        ageGroup.toLowerCase() != 'all age group') {
      query['ageGroup'] = ageGroup;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.stories, queryParameters: query),
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

  @override
  Future<ChapterDetailModel> getChapterDetail({
    required String storyId,
    required String chapterId,
  }) async {
    if (AppConfig.useMocks) {
      return ChapterPagesMock.getChapterDetail(
        storyId: storyId,
        chapterId: chapterId,
      );
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.storyChapter(storyId, chapterId)),
      (dynamic data) {
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map
            : (data is Map ? data : {});
        return ChapterDetailModel.fromJson(Map<String, dynamic>.from(map));
      },
      'Get Chapter Detail',
    );
  }

  @override
  Future<bool> updateReadingProgress({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required int percent,
    String mode = 'read',
  }) async {
    if (AppConfig.useMocks) {
      return ChapterPagesMock.updateProgress(
        storyId: storyId,
        chapterId: chapterId,
        pageNumber: pageNumber,
        percent: percent,
        mode: mode,
      );
    }
    return _client.handleRequest(
      () => _client.dio.put(
        ApiEndpoint.storyProgress(storyId),
        data: {
          'chapterId': chapterId,
          'pageNumber': pageNumber,
          'percent': percent,
          'mode': mode.toUpperCase(),
        },
      ),
      (dynamic data) => true,
      'Update Reading Progress',
    );
  }

  @override
  Future<bool> markPageRead({
    required String storyId,
    required String chapterId,
    required int pageNumber,
    required String mode,
    int? dwellSeconds,
    int? listenPercent,
  }) async {
    if (AppConfig.useMocks) {
      return true;
    }
    final body = <String, dynamic>{
      'storyId': storyId,
      'chapterId': chapterId,
      'pageNumber': pageNumber,
      'mode': mode.toUpperCase() == 'LISTEN' ? 'LISTEN' : 'READ',
    };
    if (dwellSeconds != null) body['dwellSeconds'] = dwellSeconds;
    if (listenPercent != null) body['listenPercent'] = listenPercent;

    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.pageRead, data: body),
      (dynamic data) {
        if (data is Map && data['data'] is Map) {
          return data['data']['read'] == true;
        }
        return true;
      },
      'Mark Page Read',
    );
  }

  @override
  Future<bool> completeChapter({
    required String storyId,
    required String chapterId,
  }) async {
    if (AppConfig.useMocks) {
      return ChapterPagesMock.completeChapter(
        storyId: storyId,
        chapterId: chapterId,
      );
    }
    return _client.handleRequest(
      () => _client.dio.post(
        ApiEndpoint.storyChapterComplete(storyId, chapterId),
      ),
      (dynamic data) => true,
      'Complete Chapter',
    );
  }
}
