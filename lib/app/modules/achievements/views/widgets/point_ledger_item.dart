import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/achievement_models.dart';

class PointLedgerItem extends StatelessWidget {
  const PointLedgerItem({super.key, required this.item});

  final PointLedgerItemModel item;

  IconData _iconForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('story')) {
      return Icons.menu_book_rounded;
    }
    if (cat.contains('question') || cat.contains('quiz')) {
      return Icons.star_rounded;
    }
    if (cat.contains('wings') || cat.contains('game')) {
      return Icons.sports_basketball_rounded;
    }
    if (cat.contains('participation') || cat.contains('kindness')) {
      return Icons.favorite_rounded;
    }
    return Icons.emoji_events_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFDEEE5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForCategory(item.category),
              color: AppColor.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),

          // Category & Reason
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.secondary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.subtitle,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Date & Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.dateLabel,
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.subtitle,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                item.isPositive ? '+${item.amount}' : '-${item.amount}',
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: item.isPositive ? AppColor.primary : AppColor.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
