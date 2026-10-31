/// Token payload from `POST /api/auth/student/login`.
class StudentSession {
  const StudentSession({
    required this.userId,
    required this.accessToken,
    this.status = 'ACTIVE',
  });

  final String userId;
  final String accessToken;
  final String status;

  factory StudentSession.fromJson(Map<String, dynamic> json) {
    final body = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final user = body['user'] is Map
        ? Map<String, dynamic>.from(body['user'] as Map)
        : null;
    return StudentSession(
      userId: user?['id']?.toString() ?? body['userId']?.toString() ?? '',
      accessToken: body['accessToken']?.toString() ?? '',
      status:
          user?['status']?.toString() ?? body['status']?.toString() ?? 'ACTIVE',
    );
  }
}
