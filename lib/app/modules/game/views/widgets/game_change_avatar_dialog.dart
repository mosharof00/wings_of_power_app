import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/mocks/profile.dart';

class GameChangeAvatarDialog extends StatefulWidget {
  const GameChangeAvatarDialog({
    super.key,
    required this.initialAvatar,
    required this.studentName,
    required this.onSave,
  });

  final String? initialAvatar;
  final String studentName;
  final ValueChanged<String> onSave;

  static Future<void> show({
    required BuildContext context,
    required String? initialAvatar,
    required String studentName,
    required ValueChanged<String> onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GameChangeAvatarDialog(
        initialAvatar: initialAvatar,
        studentName: studentName,
        onSave: onSave,
      ),
    );
  }

  @override
  State<GameChangeAvatarDialog> createState() => _GameChangeAvatarDialogState();
}

class _GameChangeAvatarDialogState extends State<GameChangeAvatarDialog> {
  late String _selectedAvatar;
  bool _isSaving = false;

  final List<String> _avatars = ProfileMock.presetAvatars;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = (widget.initialAvatar != null &&
            _avatars.contains(widget.initialAvatar))
        ? widget.initialAvatar!
        : _avatars.first;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      widget.onSave(_selectedAvatar);
      Get.back();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6EB),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: const Color(0xFFFFDFC8),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 32.w),
                Text(
                  widget.studentName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF6B7280),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Large Preview Circle
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFA726),
                  width: 3.w,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22FFA726),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // "Choose Your Avatar" title
            Text(
              'Choose Your Avatar',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1B4B),
              ),
            ),
            SizedBox(height: 16.h),

            // Grid of 8 face avatars (4 x 2)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _avatars.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final avatarPath = _avatars[index];
                final isSelected = avatarPath == _selectedAvatar;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatarPath;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE86726)
                            : const Color(0xFFFFDFC8),
                        width: isSelected ? 3.w : 1.5.w,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0x55E86726),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            avatarPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE86726),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE86726),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
