class LeaderboardEntry {
  final String id;
  final int rank;
  final String nickname;
  final String? avatarUrl;
  final int kindnessPoints;
  final bool isCurrentStudent;

  const LeaderboardEntry({
    required this.id,
    required this.rank,
    required this.nickname,
    this.avatarUrl,
    required this.kindnessPoints,
    this.isCurrentStudent = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      rank: json['rank'] as int? ?? 0,
      nickname: (json['nickname'] ??
              json['name'] ??
              json['studentName'] ??
              '')
          .toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      kindnessPoints: json['kindnessPoints'] as int? ??
          json['kindness_points'] as int? ??
          json['points'] as int? ??
          json['kindness'] as int? ??
          0,
      isCurrentStudent: json['isCurrentStudent'] as bool? ??
          json['is_current_student'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'nickname': nickname,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'kindnessPoints': kindnessPoints,
        'isCurrentStudent': isCurrentStudent,
      };
}

