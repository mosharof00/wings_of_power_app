import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../mocks/profile.dart';
import '../models/user_models/student_profile_model.dart';
import '../models/user_models/student_settings_model.dart';

abstract class IProfileRepository {
  Future<StudentProfileModel> getProfile();
  Future<StudentProfileModel> updateProfile({
    String? nickname,
    String? avatarUrl,
  });
  Future<StudentSettingsModel> getSettings();
  Future<StudentSettingsModel> updateSettings(StudentSettingsModel settings);
}

class ProfileRepository implements IProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  @override
  Future<StudentProfileModel> getProfile() async {
    if (AppConfig.useMocks) {
      return ProfileMock.getProfile();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.studentProfile),
      (dynamic data) =>
          StudentProfileModel.fromJson(Map<String, dynamic>.from(data as Map)),
      'Get student profile',
    );
  }

  @override
  Future<StudentProfileModel> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    if (AppConfig.useMocks) {
      return ProfileMock.updateProfile(
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
    }
    return _client.handleRequest(
      () => _client.dio.patch(
        ApiEndpoint.studentProfile,
        data: {
          'nickname': ?nickname,
          'avatarUrl': ?avatarUrl,
        },
      ),
      (dynamic data) =>
          StudentProfileModel.fromJson(Map<String, dynamic>.from(data as Map)),
      'Update student profile',
    );
  }

  @override
  Future<StudentSettingsModel> getSettings() async {
    if (AppConfig.useMocks) {
      return ProfileMock.getSettings();
    }
    return _client.handleRequest(
      () => _client.dio.get(ApiEndpoint.studentSettings),
      (dynamic data) =>
          StudentSettingsModel.fromJson(Map<String, dynamic>.from(data as Map)),
      'Get student settings',
    );
  }

  @override
  Future<StudentSettingsModel> updateSettings(StudentSettingsModel settings) async {
    if (AppConfig.useMocks) {
      return ProfileMock.updateSettings(settings);
    }
    return _client.handleRequest(
      () => _client.dio.patch(
        ApiEndpoint.studentSettings,
        data: settings.toJson(),
      ),
      (dynamic data) =>
          StudentSettingsModel.fromJson(Map<String, dynamic>.from(data as Map)),
      'Update student settings',
    );
  }
}
