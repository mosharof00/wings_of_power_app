class StudentClassInfo {
  final String id;
  final String name;

  const StudentClassInfo({required this.id, required this.name});

  factory StudentClassInfo.fromJson(Map<String, dynamic> json) {
    return StudentClassInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class StudentProfileModel {
  final String id;
  final String nickname;
  final String? realName;
  final String avatarUrl;
  final String? status;
  final int points;
  final int badges;
  final int progressPercent;
  final String ageText;
  final StudentClassInfo? studentClass;

  const StudentProfileModel({
    required this.id,
    required this.nickname,
    this.realName,
    required this.avatarUrl,
    this.status,
    required this.points,
    required this.badges,
    this.progressPercent = 0,
    this.ageText = '',
    this.studentClass,
  });

  String get displayClassName => studentClass?.name ?? '';

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    StudentClassInfo? cls;
    if (json['class'] is Map) {
      cls = StudentClassInfo.fromJson(Map<String, dynamic>.from(json['class'] as Map));
    } else if (json['className'] is String) {
      cls = StudentClassInfo(id: '', name: json['className'] as String);
    }

    return StudentProfileModel(
      id: json['id'] as String? ?? '',
      nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
      realName: json['realName'] as String?,
      avatarUrl: (json['avatarUrl'] ?? json['avatar'] ?? 'assets/images/avatar_01.png') as String,
      status: json['status'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as num?)?.toInt() ?? 0,
      progressPercent: ((json['progressPercent'] ?? json['progress']) as num?)?.toInt() ?? 0,
      ageText: _ageLabel(json['ageText'] ?? json['age']),
      studentClass: cls,
    );
  }

  static String _ageLabel(dynamic value) {
    final age = int.tryParse(value?.toString() ?? '');
    if (age == null) return value is String ? value : '';
    return age == 1 ? '1 year old' : '$age years old';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    if (realName != null) 'realName': realName,
    'avatarUrl': avatarUrl,
    if (status != null) 'status': status,
    'points': points,
    'badges': badges,
    'progressPercent': progressPercent,
    'ageText': ageText,
    if (studentClass != null) 'class': studentClass!.toJson(),
  };

  StudentProfileModel copyWith({
    String? id,
    String? nickname,
    String? realName,
    String? avatarUrl,
    String? status,
    int? points,
    int? badges,
    int? progressPercent,
    String? ageText,
    StudentClassInfo? studentClass,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      realName: realName ?? this.realName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      progressPercent: progressPercent ?? this.progressPercent,
      ageText: ageText ?? this.ageText,
      studentClass: studentClass ?? this.studentClass,
    );
  }
}
