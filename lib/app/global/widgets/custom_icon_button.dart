import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';

import '../../../gen/assets.gen.dart';
import 'custom_svg_image.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.icon,
    this.size,
    this.padding,
    this.iconColor,
    this.boxShadow,
    this.border,
  });

  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Widget? icon;
  final double? size;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 44.w,
      height: size ?? 44.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColor.primary,
        border: border,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1.r,
                offset: const Offset(1, 1),
              ),
            ],
      ),
      child: CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        child:
            icon ??
            customSvgImage(
              imagePath: Assets.icons.backArrowIcon.path,
              height: 14.h,
              width: 14.w,
              color: iconColor ?? AppColor.white,
            ),
      ),
    );
  }
}
