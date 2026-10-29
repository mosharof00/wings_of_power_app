class UserModel {
  UserModel({this.success, this.message, this.data});

  final bool? success;
  final String? message;
  final UserData? data;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    success: json['success'],
    message: json['message'],
    data: json['data'] == null ? null : UserData.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class UserData {
  UserData({
    this.id,
    this.name,
    this.username,
    this.email,
    this.avatar,
    this.about,
    this.phoneNumber,
    this.type,
    this.status,
    this.gender,
    this.dateOfBirth,
    this.emailVerified,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? username;
  final String? email;
  final String? avatar;
  final String? about;
  final String? phoneNumber;
  final String? type;
  final String? status;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool? emailVerified;
  final DateTime? createdAt;

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    email: json['email'],
    avatar: json['avatar'],
    about: json['about'],
    phoneNumber: json['phone_number'],
    type: json['type'],
    status: json['status'],
    gender: json['gender'],
    dateOfBirth: DateTime.tryParse(json['date_of_birth'] ?? ''),
    emailVerified: json['email_verified'],
    createdAt: DateTime.tryParse(json['created_at'] ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'avatar': avatar,
    'about': about,
    'phone_number': phoneNumber,
    'type': type,
    'status': status,
    'gender': gender,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'email_verified': emailVerified,
    'created_at': createdAt?.toIso8601String(),
  };
}
