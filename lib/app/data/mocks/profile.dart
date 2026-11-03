import '../models/user_models/student_profile_model.dart';
import '../models/user_models/student_settings_model.dart';

/// Fixture for student profile and settings until T-BE-011.
class ProfileMock {
  ProfileMock._();

  static const List<String> presetAvatars = [
    'assets/images/avatar_01.png',
    'assets/images/avatar_02.png',
    'assets/images/avatar_03.png',
    'assets/images/avatar_04.png',
    'assets/images/avatar_05.png',
    'assets/images/avatar_06.png',
    'assets/images/avatar_07.png',
    'assets/images/avatar_08.png',
  ];

  static StudentProfileModel _currentProfile = const StudentProfileModel(
    id: 'student-sarah',
    nickname: 'Sarah',
    realName: 'Sarah Smith',
    avatarUrl: 'assets/images/avatar_01.png',
    status: 'ACTIVE',
    points: 245,
    badges: 3,
    progressPercent: 30,
    ageText: '4 years old',
    studentClass: StudentClassInfo(
      id: 'class-grade-a',
      name: 'Grade A, Ms. Smith Class',
    ),
  );

  static StudentSettingsModel _currentSettings = const StudentSettingsModel(
    readToMe: true,
    soundEffect: true,
    notifyStories: true,
    notifyBadges: true,
    notifyGameShow: true,
    notifySafeSpace: true,
  );

  static StudentProfileModel getProfile() => _currentProfile;

  static StudentProfileModel updateProfile({
    String? nickname,
    String? avatarUrl,
  }) {
    _currentProfile = _currentProfile.copyWith(
      nickname: nickname?.trim(),
      avatarUrl: avatarUrl?.trim(),
    );
    return _currentProfile;
  }

  static StudentSettingsModel getSettings() => _currentSettings;

  static StudentSettingsModel updateSettings(StudentSettingsModel settings) {
    _currentSettings = settings;
    return _currentSettings;
  }

  static void reset() {
    _currentProfile = const StudentProfileModel(
      id: 'student-sarah',
      nickname: 'Sarah',
      realName: 'Sarah Smith',
      avatarUrl: 'assets/images/avatar_01.png',
      status: 'ACTIVE',
      points: 245,
      badges: 3,
      progressPercent: 30,
      ageText: '4 years old',
      studentClass: StudentClassInfo(
        id: 'class-grade-a',
        name: 'Grade A, Ms. Smith Class',
      ),
    );
    _currentSettings = const StudentSettingsModel(
      readToMe: true,
      soundEffect: true,
      notifyStories: true,
      notifyBadges: true,
      notifyGameShow: true,
      notifySafeSpace: true,
    );
  }
}
