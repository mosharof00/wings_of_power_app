import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/safe_space_models.dart';
import '../controllers/safe_space_controller.dart';
import '../widgets/safe_space_report_detail_sheet.dart';

class SafeSpaceReportDetailView extends StatefulWidget {
  const SafeSpaceReportDetailView({super.key});

  @override
  State<SafeSpaceReportDetailView> createState() =>
      _SafeSpaceReportDetailViewState();
}

class _SafeSpaceReportDetailViewState
    extends State<SafeSpaceReportDetailView> {
  late final SafeSpaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SafeSpaceController>();
    final id = Get.parameters['id'];
    if (id != null && id.isNotEmpty) {
      _controller.loadReportDetail(id);
    } else if (Get.arguments is SafeSpaceReportModel) {
      _controller.detailReport.value = Get.arguments as SafeSpaceReportModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x59000000),
      body: Stack(
        children: [
          // ── Blurred Backdrop ─────────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // ── Centered Modal Card ──────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
              child: Obx(() {
                if (_controller.isLoadingDetail.value &&
                    _controller.detailReport.value == null) {
                  return Container(
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: const CircularProgressIndicator(),
                  );
                }

                final report = _controller.detailReport.value ??
                    SafeSpaceReportModel(
                      id: 'rep-1',
                      publicRef: 'WP-1548',
                      category: SafeSpaceCategory.hurtfulWords,
                      body:
                          'Someone made fun of me and said hurtful things during school.',
                      feelSafe: true,
                      status: 'NEW',
                      submittedAt: DateTime(2026, 10, 18, 9, 30),
                    );

                return SafeSpaceReportDetailSheet(
                  report: report,
                  onClose: () => Get.back(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
