import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wings_of_power_app/app/core/theme/app_color.dart';
import 'package:wings_of_power_app/app/data/models/home_models.dart';
import 'package:wings_of_power_app/app/global/widgets/app_text.dart';
import 'package:wings_of_power_app/gen/assets.gen.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.52);
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
          height: 205.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.categories.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final delta = (index - _currentPage).abs();
              final scale = (1.0 - (delta * 0.12)).clamp(0.86, 1.0);
              final opacity = (1.0 - (delta * 0.15)).clamp(0.75, 1.0);

              return Center(
                child: SizedBox(
                  height: 205.h * scale,
                  width: 175.w,
                  child: Opacity(
                    opacity: opacity,
                    child: GestureDetector(
                      onTap: () => widget.onCategoryTap?.call(category),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background category illustration
                              _buildCategoryCover(category),
                              // Bottom gradient shadow for readable text
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.1),
                                      Colors.black.withValues(alpha: 0.75),
                                    ],
                                    stops: const [0.3, 0.6, 1.0],
                                  ),
                                ),
                              ),
                              // Text at bottom
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
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    AppText(
                                      '${category.storyCount} Stories',
                                      style: TextStyle(
                                        color: AppColor.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.sp,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCover(HomeCategoryModel category) {
    if (category.imageUrl != null && category.imageUrl!.startsWith('http')) {
      return Image.network(
        category.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultImage(category),
      );
    }
    if (category.assetPath != null && category.assetPath!.isNotEmpty) {
      return Image.asset(
        category.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultImage(category),
      );
    }
    return _defaultImage(category);
  }

  Widget _defaultImage(HomeCategoryModel category) {
    if (category.title.toLowerCase().contains('courage')) {
      return Assets.images.categoryCourage.image(fit: BoxFit.cover);
    }
    return Assets.images.categoryKindness.image(fit: BoxFit.cover);
  }
}
