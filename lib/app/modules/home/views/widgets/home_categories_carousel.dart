import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/app/global/widgets/cached_image.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

/// Stacked / overlapping book-category cards (design: Home Book Categories).
class HomeCategoriesCarousel extends StatefulWidget {
  const HomeCategoriesCarousel({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<HomeCategoryModel> categories;
  final ValueChanged<HomeCategoryModel>? onCategoryTap;

  @override
  State<HomeCategoriesCarousel> createState() => _HomeCategoriesCarouselState();
}

class _HomeCategoriesCarouselState extends State<HomeCategoriesCarousel> {
  late final PageController _pageController;
  double _currentPage = 0.0;

  static const double _viewportFraction = 0.42;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      // Left-align first card like design (not centered with empty gutters).
    );
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

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
        SizedBox(
          height: 210.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.categories.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final delta = index - _currentPage;
              final absDelta = delta.abs();
              // Pull neighbors under the focused card (fan / stacked deck).
              final overlapPull = -delta * 52.w;
              final scale = (1.0 - (absDelta * 0.1)).clamp(0.78, 1.0);
              final opacity = (1.0 - (absDelta * 0.18)).clamp(0.55, 1.0);

              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16.w : 0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..translateByDouble(overlapPull, absDelta * 6.h, 0, 1)
                      ..scaleByDouble(scale, scale, 1, 1),
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        height: 200.h,
                        width: 150.w,
                        child: GestureDetector(
                          onTap: () => widget.onCategoryTap?.call(category),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.14 * (1 - absDelta.clamp(0, 1)),
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: AppColor.white
                                                .withValues(alpha: 0.92),
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
                      ),
                    ),
                  ),
                ),
              );
            },
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
    return Image.asset(
      Assets.images.placeholderImage.path,
      fit: BoxFit.cover,
    );
  }
}
