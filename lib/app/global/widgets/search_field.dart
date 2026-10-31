import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/core/theme/app_radius.dart';

import 'app_input_text_form_field.dart';

/// White search pill. The trailing slot is the filter control on Home and the library.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onFilterTap,
    this.filterIcon,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final Widget? filterIcon;

  @override
  Widget build(BuildContext context) {
    return AppInputTextFormField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      borderRadius: AppRadius.search,
      showBorder: false,
      fillColor: AppColor.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      prefixIcon: Icon(Icons.search, color: AppColor.hintText, size: 20.sp),
      suffixIcon: IconButton(
        onPressed: onFilterTap,
        icon: filterIcon ??
            Icon(Icons.tune, color: AppColor.secondary, size: 20.sp),
      ),
    );
  }
}
