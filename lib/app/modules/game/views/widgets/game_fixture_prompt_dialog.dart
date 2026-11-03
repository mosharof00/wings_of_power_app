import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GameFixturePromptDialog extends StatefulWidget {
  const GameFixturePromptDialog({
    super.key,
    required this.initialCode,
    required this.onSave,
    required this.onStartMatch,
  });

  final String? initialCode;
  final ValueChanged<String?> onSave;
  final ValueChanged<String?> onStartMatch;

  static Future<void> show({
    required BuildContext context,
    required String? initialCode,
    required ValueChanged<String?> onSave,
    required ValueChanged<String?> onStartMatch,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GameFixturePromptDialog(
        initialCode: initialCode,
        onSave: onSave,
        onStartMatch: onStartMatch,
      ),
    );
  }

  @override
  State<GameFixturePromptDialog> createState() =>
      _GameFixturePromptDialogState();
}

class _GameFixturePromptDialogState extends State<GameFixturePromptDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6EB),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFFFDFC8), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.developer_mode_rounded,
                  color: const Color(0xFFE86726),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Dev Fixture Code',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'Set a matching fixture code on two test simulators to pair into the same practice match (e.g. desk-1). Leave empty for normal solo bot practice.',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: const Color(0xFF4B5563),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'e.g. desk-1',
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 14.sp,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFFFDFC8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFFFDFC8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      const BorderSide(color: Color(0xFFE86726), width: 2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                if (_textController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _textController.clear();
                      widget.onSave(null);
                      Get.back();
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    final code = _textController.text.trim();
                    final finalCode = code.isEmpty ? null : code;
                    widget.onSave(finalCode);
                    Get.back();
                    widget.onStartMatch(finalCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE86726),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    'Start Match',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
