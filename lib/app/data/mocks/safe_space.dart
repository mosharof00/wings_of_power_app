import '../models/safe_space_models.dart';

class SafeSpaceMock {
  SafeSpaceMock._();

  static final List<SafeSpaceReportModel> _initialReports = [
    SafeSpaceReportModel(
      id: 'rep-1',
      publicRef: 'WP-1548',
      category: SafeSpaceCategory.hurtfulWords,
      body: 'Someone made fun of me and said hurtful things during school.',
      feelSafe: true,
      status: 'NEW',
      submittedAt: DateTime(2026, 10, 18, 9, 30),
      createdAt: DateTime(2026, 10, 18, 9, 30),
      updatedAt: DateTime(2026, 10, 18, 9, 30),
    ),
    SafeSpaceReportModel(
      id: 'rep-2',
      publicRef: 'WP-1549',
      category: SafeSpaceCategory.cyberbullying,
      body: 'Online incident submitted regarding hurtful group messages.',
      feelSafe: false,
      status: 'REVIEWING',
      submittedAt: DateTime(2026, 10, 18, 9, 30),
      createdAt: DateTime(2026, 10, 18, 9, 30),
      updatedAt: DateTime(2026, 10, 18, 9, 30),
    ),
    SafeSpaceReportModel(
      id: 'rep-3',
      publicRef: 'WP-1550',
      category: SafeSpaceCategory.physicalPush,
      body: 'Physical incident submitted regarding rough pushing on the playground.',
      feelSafe: false,
      status: 'ADDRESSED',
      submittedAt: DateTime(2026, 10, 18, 9, 30),
      createdAt: DateTime(2026, 10, 18, 9, 30),
      updatedAt: DateTime(2026, 10, 18, 9, 30),
    ),
  ];

  static List<SafeSpaceReportModel> _reports = List.from(_initialReports);

  static void reset() {
    _reports = List.from(_initialReports);
  }

  static SafeSpaceReportsResponseModel getReports({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    List<SafeSpaceReportModel> filtered = _reports;
    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
      final s = status.toUpperCase();
      filtered = _reports.where((r) => r.status.toUpperCase() == s).toList();
    }

    final total = filtered.length;
    final startIndex = (page - 1) * perPage;
    final items = startIndex < total
        ? filtered.skip(startIndex).take(perPage).toList()
        : <SafeSpaceReportModel>[];

    return SafeSpaceReportsResponseModel(
      items: items,
      total: total,
      page: page,
      perPage: perPage,
      lastPage: (total / perPage).ceil().clamp(1, 9999),
    );
  }

  static SafeSpaceReportModel getReportById(String idOrRef) {
    try {
      return _reports.firstWhere(
        (r) => r.id == idOrRef || r.publicRef == idOrRef,
      );
    } catch (_) {
      // Default to the first report (WP-1548) if ID not found
      return _reports.first;
    }
  }

  static SafeSpaceReportModel createReport(CreateSafeSpaceReportRequest req) {
    final nextNumber = 1548 + _reports.length;
    final newReport = SafeSpaceReportModel(
      id: 'rep-${_reports.length + 1}',
      publicRef: 'WP-$nextNumber',
      category: req.category,
      body: req.body,
      feelSafe: req.feelSafe,
      status: 'NEW',
      submittedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _reports.insert(0, newReport);
    return newReport;
  }
}
