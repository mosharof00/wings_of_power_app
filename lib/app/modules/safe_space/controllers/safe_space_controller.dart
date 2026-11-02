import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';
import 'package:wings_of_power_app/app/data/repositories/safe_space_repository.dart';
import 'package:wings_of_power_app/app/routes/app_pages.dart';

class SafeSpaceController extends GetxController {
  final ISafeSpaceRepository _repository;

  SafeSpaceController(this._repository);

  // ── Form State ──────────────────────────────────────────────────────────
  final currentStep = 1.obs; // 1, 2, 3
  final selectedCategory = RxnString();
  final bodyTextController = TextEditingController();
  final characterCount = 0.obs;
  final feelSafe = RxnBool();
  final isSubmitting = false.obs;
  final submittedReport = Rxn<SafeSpaceReportModel>();
  final formError = RxnString();

  static const int maxBodyLength = 200;

  // ── Reports List State ─────────────────────────────────────────────────
  final selectedFilter = 'ALL'.obs; // 'ALL', 'NEW', 'REVIEWING', 'ADDRESSED'
  final reports = <SafeSpaceReportModel>[].obs;
  final isLoadingReports = false.obs;
  final reportsError = RxnString();

  // ── Report Detail State ────────────────────────────────────────────────
  final detailReport = Rxn<SafeSpaceReportModel>();
  final isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    bodyTextController.addListener(_onTextChanged);
    fetchReports();
  }

  @override
  void onClose() {
    bodyTextController.removeListener(_onTextChanged);
    bodyTextController.dispose();
    super.onClose();
  }

  void _onTextChanged() {
    final text = bodyTextController.text;
    if (text.length > maxBodyLength) {
      bodyTextController.text = text.substring(0, maxBodyLength);
      bodyTextController.selection = TextSelection.fromPosition(
        const TextPosition(offset: maxBodyLength),
      );
    }
    characterCount.value = bodyTextController.text.length;
  }

  // ── Form Navigation & Actions ──────────────────────────────────────────

  void startNewReport() {
    resetForm();
    Get.toNamed(Routes.SAFE_SPACE_FORM);
  }

  void resetForm() {
    currentStep.value = 1;
    selectedCategory.value = null;
    bodyTextController.clear();
    characterCount.value = 0;
    feelSafe.value = null;
    isSubmitting.value = false;
    formError.value = null;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  bool get canProceedStep1 =>
      selectedCategory.value != null && selectedCategory.value!.isNotEmpty;

  void selectFeelSafe(bool value) {
    feelSafe.value = value;
  }

  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedCategory.value!.isNotEmpty &&
      feelSafe.value != null &&
      !isSubmitting.value;

  void nextStep() {
    if (currentStep.value == 1) {
      if (!canProceedStep1) return;
      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      currentStep.value = 3;
    } else if (currentStep.value == 3) {
      submitReport();
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value -= 1;
    } else {
      Get.back();
    }
  }

  void cancelForm() {
    resetForm();
    Get.offAllNamed(Routes.MAIN_PAGE);
  }

  Future<void> submitReport() async {
    if (!canSubmit) return;

    try {
      isSubmitting.value = true;
      formError.value = null;

      final request = CreateSafeSpaceReportRequest(
        category: selectedCategory.value!,
        body: bodyTextController.text.trim(),
        feelSafe: feelSafe.value ?? false,
      );

      final created = await _repository.createReport(request);
      submittedReport.value = created;

      // Refresh list so it includes the newly created report
      await fetchReports();

      Get.offNamed(Routes.SAFE_SPACE_DONE, arguments: created);
    } catch (e) {
      formError.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Reports List Actions ───────────────────────────────────────────────

  Future<void> fetchReports({String? filter}) async {
    try {
      isLoadingReports.value = true;
      reportsError.value = null;
      final targetFilter = filter ?? selectedFilter.value;
      final response = await _repository.getReports(
        status: targetFilter,
      );
      reports.assignAll(response.items);
    } catch (e) {
      reportsError.value = e.toString();
    } finally {
      isLoadingReports.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchReports(filter: filter);
  }

  List<SafeSpaceReportModel> get filteredReports {
    final f = selectedFilter.value.toUpperCase();
    if (f == 'ALL') {
      return reports;
    }
    return reports.where((r) => r.status.toUpperCase() == f).toList();
  }

  // ── Report Detail Actions ──────────────────────────────────────────────

  Future<void> loadReportDetail(String id) async {
    // If argument passed was already a model, use it immediately
    if (Get.arguments is SafeSpaceReportModel) {
      detailReport.value = Get.arguments as SafeSpaceReportModel;
      return;
    }

    try {
      isLoadingDetail.value = true;
      final report = await _repository.getReportDetail(id);
      detailReport.value = report;
    } catch (_) {
      // If error or not found, try to locate in current reports list
      final local = reports.firstWhereOrNull((r) => r.id == id || r.publicRef == id);
      if (local != null) {
        detailReport.value = local;
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void openReportDetail(SafeSpaceReportModel report) {
    detailReport.value = report;
    Get.toNamed(
      '${Routes.SAFE_SPACE_REPORTS}/${report.id}',
      arguments: report,
    );
  }
}
