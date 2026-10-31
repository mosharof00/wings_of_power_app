class JoinCodePreview {
  const JoinCodePreview({
    required this.className,
    required this.teacherName,
    required this.classId,
  });

  final String className;
  final String teacherName;
  final String classId;

  factory JoinCodePreview.fromJson(Map<String, dynamic> json) {
    final body = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return JoinCodePreview(
      className: body['className']?.toString() ?? '',
      teacherName: body['teacherName']?.toString() ?? '',
      classId: body['classId']?.toString() ?? '',
    );
  }
}
