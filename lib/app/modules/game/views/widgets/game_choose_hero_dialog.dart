import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/hero_models.dart';
import 'package:wings_of_power_app/app/data/repositories/igame_repository.dart';

class GameChooseHeroDialog extends StatefulWidget {
  const GameChooseHeroDialog({
    super.key,
    required this.repository,
    this.currentSelectedHeroId,
    required this.onHeroSelected,
  });

  final IGameRepository repository;
  final String? currentSelectedHeroId;
  final ValueChanged<HeroModel> onHeroSelected;

  static Future<void> show({
    required BuildContext context,
    required IGameRepository repository,
    String? currentSelectedHeroId,
    required ValueChanged<HeroModel> onHeroSelected,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GameChooseHeroDialog(
        repository: repository,
        currentSelectedHeroId: currentSelectedHeroId,
        onHeroSelected: onHeroSelected,
      ),
    );
  }

  @override
  State<GameChooseHeroDialog> createState() => _GameChooseHeroDialogState();
}

class _GameChooseHeroDialogState extends State<GameChooseHeroDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  List<HeroModel> _heroes = [];
  String? _selectedId;
  String? _selectingId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentSelectedHeroId;
    _fetchHeroes();
  }

  Future<void> _fetchHeroes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await widget.repository.getHeroes();
      if (mounted) {
        setState(() {
          _heroes = list;
          _isLoading = false;
          if (_selectedId == null) {
            final selected = list.firstWhereOrNull((h) => h.isSelected);
            if (selected != null) {
              _selectedId = selected.id;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleHeroTap(HeroModel hero) async {
    if (!hero.isUnlocked) {
      _showLockedDialog(hero);
      return;
    }

    if (_selectingId != null) return;

    setState(() => _selectingId = hero.id);
    try {
      final updatedHero = await widget.repository.selectHero(hero.id);
      if (mounted) {
        setState(() {
          _selectedId = updatedHero.id;
        });
      }
      widget.onHeroSelected(updatedHero);
      Get.back();
      Get.snackbar(
        'Hero Selected',
        '${hero.displayName} is now your Power Hero!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE86726),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Selection Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _selectingId = null);
      }
    }
  }

  void _showLockedDialog(HeroModel hero) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6EB),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFFFDFC8), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 48.sp,
                color: const Color(0xFFE86726),
              ),
              SizedBox(height: 12.h),
              Text(
                'Unlock ${hero.displayName}!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Complete 2 stories to unlock a new hero! Every story brings you closer to your next adventure.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: const Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE86726),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                  ),
                  child: const Text('Got It'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
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
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 32.w),
                Text(
                  'Choose Power Hero',
                  style: TextStyle(
                    fontSize: 20.sp,
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
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
            SizedBox(height: 16.h),

            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE86726),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Text(
                      'Failed to load heroes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: _fetchHeroes,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else
              // Grid of heroes
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 380.h),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _heroes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final hero = _heroes[index];
                    final isSelected = hero.id == _selectedId;
                    final isUnlocked = hero.isUnlocked;
                    final isBusy = hero.id == _selectingId;

                    return GestureDetector(
                      onTap: () => _handleHeroTap(hero),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE86726)
                                : (isUnlocked
                                    ? const Color(0xFFFFDFC8)
                                    : const Color(0xFFE5E7EB)),
                            width: isSelected ? 2.5.w : 1.w,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0x44E86726),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          hero.assetPath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        if (!isUnlocked)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.65),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: EdgeInsets.all(6.w),
                                            child: Icon(
                                              Icons.lock_rounded,
                                              size: 22.sp,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    hero.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked
                                          ? const Color(0xFF1E1B4B)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Text(
                                    hero.powerLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFE86726),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4.w,
                                right: 4.w,
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
                            if (isBusy)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
