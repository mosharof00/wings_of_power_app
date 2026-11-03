class StudentSettingsModel {
  final bool readToMe;
  final bool soundEffect;
  final bool notifyStories;
  final bool notifyBadges;
  final bool notifyGameShow;
  final bool notifySafeSpace;

  const StudentSettingsModel({
    this.readToMe = true,
    this.soundEffect = true,
    this.notifyStories = true,
    this.notifyBadges = true,
    this.notifyGameShow = true,
    this.notifySafeSpace = true,
  });

  factory StudentSettingsModel.fromJson(Map<String, dynamic> json) {
    final notifs = json['notifications'] is Map
        ? Map<String, dynamic>.from(json['notifications'] as Map)
        : <String, dynamic>{};

    return StudentSettingsModel(
      readToMe: json['read_to_me'] as bool? ?? json['readToMe'] as bool? ?? true,
      soundEffect: json['sound'] as bool? ?? json['soundEffect'] as bool? ?? true,
      notifyStories: notifs['stories'] as bool? ?? json['notifyStories'] as bool? ?? true,
      notifyBadges: notifs['badges'] as bool? ?? json['notifyBadges'] as bool? ?? true,
      notifyGameShow: notifs['game_show'] as bool? ?? json['notifyGameShow'] as bool? ?? true,
      notifySafeSpace: notifs['safe_space'] as bool? ?? json['notifySafeSpace'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'read_to_me': readToMe,
    'sound': soundEffect,
    'notifications': {
      'stories': notifyStories,
      'badges': notifyBadges,
      'game_show': notifyGameShow,
      'safe_space': notifySafeSpace,
    },
  };

  StudentSettingsModel copyWith({
    bool? readToMe,
    bool? soundEffect,
    bool? notifyStories,
    bool? notifyBadges,
    bool? notifyGameShow,
    bool? notifySafeSpace,
  }) {
    return StudentSettingsModel(
      readToMe: readToMe ?? this.readToMe,
      soundEffect: soundEffect ?? this.soundEffect,
      notifyStories: notifyStories ?? this.notifyStories,
      notifyBadges: notifyBadges ?? this.notifyBadges,
      notifyGameShow: notifyGameShow ?? this.notifyGameShow,
      notifySafeSpace: notifySafeSpace ?? this.notifySafeSpace,
    );
  }
}
