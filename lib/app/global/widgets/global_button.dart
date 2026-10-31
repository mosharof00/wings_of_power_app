import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wings_of_power_app/app/core/extensions/text_style_extension.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';
import 'package:wings_of_power_app/app/core/theme/app_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text.dart';

enum GlobalButtonVariant { primary, secondary, text }

class GlobalButton extends StatelessWidget {
  const GlobalButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.borderColor,
    this.textColor,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.gradient,
    this.boxShadow,
    this.suffixWidget,
    this.prefixWidget,
    this.padding,
    this.isDisabled = false,
    this.isLoading = false,
    this.variant = GlobalButtonVariant.primary,
    this.widget,
    this.textStyle,
  });

  final VoidCallback onTap;
  final String text;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final Widget? widget;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final bool isLoading;
  final GlobalButtonVariant variant;
  final TextStyle? textStyle;

  bool get _blocked => isDisabled || isLoading;

  Color _fill() {
    if (isDisabled) return AppColor.primaryDisable;
    if (color != null) return color!;
    return switch (variant) {
      GlobalButtonVariant.primary => AppColor.primary,
      GlobalButtonVariant.secondary => AppColor.white,
      GlobalButtonVariant.text => Colors.transparent,
    };
  }

  Color _labelColor() {
    if (textColor != null) return textColor!;
    if (isDisabled) return AppColor.white;
    return switch (variant) {
      GlobalButtonVariant.primary => AppColor.white,
      GlobalButtonVariant.secondary => AppColor.primary,
      GlobalButtonVariant.text => AppColor.primary,
    };
  }

  List<BoxShadow>? _shadow() {
    if (isDisabled || variant != GlobalButtonVariant.primary) return null;
    if (boxShadow != null) return boxShadow;
    return AppShadow.button
        .map(
          (shadow) => BoxShadow(
            color: shadow.color,
            offset: Offset(shadow.offset.dx, shadow.offset.dy.h),
            blurRadius: shadow.blurRadius,
            spreadRadius: shadow.spreadRadius,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: _blocked ? null : onTap,
      padding: padding ?? EdgeInsets.zero,
      minimumSize: Size.zero,
      child: Container(
        height: height ?? 44.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: gradient == null || isDisabled ? _fill() : null,
          gradient: isDisabled ? null : gradient,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppRadius.button.r),
          border: Border.all(color: borderColor ?? Colors.transparent),
          boxShadow: _shadow(),
        ),
        alignment: Alignment.center,
        child: widget ??
            (isLoading
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _labelColor(),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ?prefixWidget,
                      Expanded(
                        child: AppText(
                          text,
                          style: textStyle ??
                              context.titleSmall.copyWith(
                                color: _labelColor(),
                                fontSize: fontSize,
                                fontWeight: fontWeight ?? FontWeight.w700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ?suffixWidget,
                    ],
                  )),
      ),
    );
  }
}
