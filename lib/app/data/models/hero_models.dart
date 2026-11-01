class HeroModel {
  const HeroModel({
    required this.id,
    required this.code,
    required this.displayName,
    required this.roleTitle,
    required this.bulliedFor,
    required this.powerCode,
    required this.powerLabel,
    required this.powerDescription,
    required this.quote,
    required this.assetPath,
    this.artUrl,
    required this.sortOrder,
    this.unlockStoriesRequired = 0,
    this.isUnlocked = false,
    this.isSelected = false,
  });

  final String id;
  final String code;
  final String displayName;
  final String roleTitle;
  final String bulliedFor;
  final String powerCode;
  final String powerLabel;
  final String powerDescription;
  final String quote;
  final String assetPath;
  final String? artUrl;
  final int sortOrder;
  final int unlockStoriesRequired;
  final bool isUnlocked;
  final bool isSelected;

  String get fullNameRole => '$displayName - $roleTitle';

  String get powerSummary => 'Power: $powerLabel - $powerDescription';

  HeroModel copyWith({
    String? id,
    String? code,
    String? displayName,
    String? roleTitle,
    String? bulliedFor,
    String? powerCode,
    String? powerLabel,
    String? powerDescription,
    String? quote,
    String? assetPath,
    String? artUrl,
    int? sortOrder,
    int? unlockStoriesRequired,
    bool? isUnlocked,
    bool? isSelected,
  }) {
    return HeroModel(
      id: id ?? this.id,
      code: code ?? this.code,
      displayName: displayName ?? this.displayName,
      roleTitle: roleTitle ?? this.roleTitle,
      bulliedFor: bulliedFor ?? this.bulliedFor,
      powerCode: powerCode ?? this.powerCode,
      powerLabel: powerLabel ?? this.powerLabel,
      powerDescription: powerDescription ?? this.powerDescription,
      quote: quote ?? this.quote,
      assetPath: assetPath ?? this.assetPath,
      artUrl: artUrl ?? this.artUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      unlockStoriesRequired:
          unlockStoriesRequired ?? this.unlockStoriesRequired,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      displayName: json['display_name']?.toString() ??
          json['displayName']?.toString() ??
          '',
      roleTitle: json['role_title']?.toString() ??
          json['roleTitle']?.toString() ??
          '',
      bulliedFor: json['bullied_for']?.toString() ??
          json['bulliedFor']?.toString() ??
          '',
      powerCode: json['power_code']?.toString() ??
          json['powerCode']?.toString() ??
          '',
      powerLabel: json['power_label']?.toString() ??
          json['powerLabel']?.toString() ??
          '',
      powerDescription: json['power_description']?.toString() ??
          json['powerDescription']?.toString() ??
          '',
      quote: json['quote']?.toString() ?? '',
      assetPath: json['asset_path']?.toString() ??
          json['assetPath']?.toString() ??
          'assets/characters/hero_${json['code']?.toString().toLowerCase() ?? 'faith'}.png',
      artUrl: json['art_url']?.toString() ?? json['artUrl']?.toString(),
      sortOrder: (json['sort_order'] ?? json['sortOrder'] ?? 0) as int,
      unlockStoriesRequired: (json['unlock_stories_required'] ??
              json['unlockStoriesRequired'] ??
              0) as int,
      isUnlocked: (json['is_unlocked'] ?? json['isUnlocked'] ?? false) as bool,
      isSelected: (json['is_selected'] ?? json['isSelected'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'display_name': displayName,
      'role_title': roleTitle,
      'bullied_for': bulliedFor,
      'power_code': powerCode,
      'power_label': powerLabel,
      'power_description': powerDescription,
      'quote': quote,
      'asset_path': assetPath,
      'art_url': artUrl,
      'sort_order': sortOrder,
      'unlock_stories_required': unlockStoriesRequired,
      'is_unlocked': isUnlocked,
      'is_selected': isSelected,
    };
  }
}
