import 'package:intl/intl.dart';

class SafeSpaceCategory {
  SafeSpaceCategory._();

  static const String hurtfulWords = 'Hurtful Words & Teasing';
  static const String cyberbullying = 'Cyberbullying';
  static const String physicalPush = 'Physical Push or Unsafe Behavior';
  static const String somethingElse = 'Something Else';

  static const List<String> all = [
    hurtfulWords,
    cyberbullying,
    physicalPush,
    somethingElse,
  ];
}

class SafeSpaceReportModel {
  final String id;
  final String publicRef;
  final String category;
  final String body;
  final bool feelSafe;
  final String status;
  final DateTime submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? assigneeId;
  final String? assigneeName;
  final String? classId;
  final String? className;

  SafeSpaceReportModel({
    required this.id,
    required this.publicRef,
    required this.category,
    required this.body,
    required this.feelSafe,
    required this.status,
    required this.submittedAt,
    this.createdAt,
    this.updatedAt,
    this.assigneeId,
    this.assigneeName,
    this.classId,
    this.className,
  });

  String get displayStatus {
    final s = status.toUpperCase();
    if (s == 'NEW') return 'New';
    if (s == 'REVIEWING') return 'Reviewing';
    if (s == 'ADDRESSED') return 'Addressed';
    return status;
  }

  String get shortSubmittedDate {
    return DateFormat('MMM d, yyyy').format(submittedAt);
  }

  String get longSubmittedDate {
    return DateFormat('MMMM d, yyyy').format(submittedAt);
  }

  factory SafeSpaceReportModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final rawRef = json['publicRef'] ?? json['public_ref'] ?? json['ref'] ?? '';
    final id = (json['id'] ?? rawRef).toString();
    final publicRef = (rawRef.toString().isNotEmpty ? rawRef : id).toString();

    return SafeSpaceReportModel(
      id: id,
      publicRef: publicRef.isNotEmpty ? publicRef : 'WP-1548',
      category: (json['category'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      feelSafe: json['feelSafe'] == true ||
          json['feel_safe'] == true ||
          json['feelSafe'] == 'true',
      status: (json['status'] ?? 'NEW').toString().toUpperCase(),
      submittedAt: parseDate(json['submittedAt'] ?? json['submitted_at'] ?? json['createdAt']),
      createdAt: json['createdAt'] != null ? parseDate(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      assigneeId: json['assigneeId']?.toString(),
      assigneeName: json['assignee'] is Map
          ? (json['assignee']['nickname'] ?? json['assignee']['realName'])?.toString()
          : json['assigneeName']?.toString(),
      classId: json['classId']?.toString(),
      className: json['class'] is Map
          ? json['class']['name']?.toString()
          : json['className']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicRef': publicRef,
      'category': category,
      'body': body,
      'feelSafe': feelSafe,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (assigneeName != null) 'assigneeName': assigneeName,
      if (classId != null) 'classId': classId,
      if (className != null) 'className': className,
    };
  }
}

class SafeSpaceReportsResponseModel {
  final List<SafeSpaceReportModel> items;
  final int total;
  final int page;
  final int perPage;
  final int lastPage;

  SafeSpaceReportsResponseModel({
    required this.items,
    this.total = 0,
    this.page = 1,
    this.perPage = 20,
    this.lastPage = 1,
  });

  factory SafeSpaceReportsResponseModel.fromJson(Map<String, dynamic> json) {
    List<SafeSpaceReportModel> parseItems(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(SafeSpaceReportModel.fromJson)
            .toList();
      }
      return <SafeSpaceReportModel>[];
    }

    final rawItems = json['items'] ?? json['data'] ?? [];
    final items = parseItems(rawItems);

    return SafeSpaceReportsResponseModel(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['perPage'] as num?)?.toInt() ?? 20,
      lastPage: (json['lastPage'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'perPage': perPage,
      'lastPage': lastPage,
    };
  }
}

class CreateSafeSpaceReportRequest {
  final String category;
  final String body;
  final bool feelSafe;

  CreateSafeSpaceReportRequest({
    required this.category,
    required this.body,
    required this.feelSafe,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'body': body,
      'feelSafe': feelSafe,
    };
  }
}
