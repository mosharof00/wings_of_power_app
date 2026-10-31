import '../user_models/user_model.dart';

class RegisterResult {
  const RegisterResult({required this.user, required this.accessToken});

  final UserModel user;
  final String accessToken;

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    final body = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final userJson = body['user'] is Map
        ? Map<String, dynamic>.from(body['user'] as Map)
        : body;
    return RegisterResult(
      user: UserModel(success: true, data: UserData.fromJson(userJson)),
      accessToken: body['accessToken']?.toString() ?? '',
    );
  }
}
