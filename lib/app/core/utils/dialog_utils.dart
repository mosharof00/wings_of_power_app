import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../global/widgets/custom_dialog.dart';
import '../../global/widgets/global_button.dart';

class DialogUtils {
  static void showDialog({
    required BuildContext context,
    required String title,
    required String description,
    DialogType dialogType = DialogType.info,
    String? okText,
    String? cancelText,
    VoidCallback? okOnPress,
    VoidCallback? cancelOnPress,
    VoidCallback? onDismiss,
    bool dismissOnTouchOutside = true,
    bool dismissOnBackKeyPress = true,
  }) {
    final showCancel = cancelOnPress != null || cancelText != null;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: dismissOnTouchOutside,
      enableDrag: dismissOnTouchOutside,
      isScrollControlled: true,
      builder: (sheetContext) {
        return PopScope(
          canPop: dismissOnBackKeyPress,
          child: CustomDialog(
            title: title,
            subtitle: description,
            bottomWidget: Column(
              children: [
                GlobalButton(
                  text: okText ?? 'OK',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    okOnPress?.call();
                  },
                ),
                if (showCancel) ...[
                  SizedBox(height: 10.h),
                  GlobalButton(
                    text: cancelText ?? 'Cancel',
                    variant: GlobalButtonVariant.secondary,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      cancelOnPress?.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => onDismiss?.call());
  }
}
