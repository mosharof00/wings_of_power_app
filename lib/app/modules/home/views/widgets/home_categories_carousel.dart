import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/cached_image.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

/// Horizontal stacked book-category cards (design: Home Book Categories).
///
/// Uses [carousel_slider] — `vertical_card_pager` is vertical-only.
class HomeCategoriesCarousel extends StatelessWidget {
  const HomeCategoriesCarousel({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<HomeCategoryModel> categories;
  final ValueChanged<HomeCategoryModel>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AppText(
            'Book Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        CarouselSlider.builder(
          itemCount: categories.length,
          itemBuilder: (context, index, _) {
            final category = categories[index];
            return Padding(
              // Negative horizontal inset pulls neighbors into a stacked fan.
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: GestureDetector(
                onTap: () => onCategoryTap?.call(category),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildCategoryCover(category),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0x14000000),
                                Color(0xC7000000),
                              ],
                              stops: [0.35, 0.62, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12.w,
                          right: 12.w,
                          bottom: 12.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppText(
                                category.title,
                                maxLines: 2,
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  height: 1.15,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              AppText(
                                '${category.storyCount} Stories',
                                style: TextStyle(
                                  color: AppColor.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 210.h,
            viewportFraction: 0.48,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            padEnds: false,
            enableInfiniteScroll: false,
            autoPlay: false,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCover(HomeCategoryModel category) {
    final url = category.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return CachedImage(
        imgUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.asset(Assets.images.otherCategories.path, fit: BoxFit.cover);
  }
}
