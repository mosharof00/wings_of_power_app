import 'package:get/get.dart';
import '../../../data/models/story_models.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../routes/app_pages.dart';

class ReaderController extends GetxController {
  ReaderController([IStoryRepository? repository])
      : _repository = repository ?? Get.find<IStoryRepository>();

  final IStoryRepository _repository;

  String storyId = 'story-golden-pearl-1';
  String chapterId = 'gp1-ch-1';

  final isLoading = true.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;
  final chapter = Rxn<ChapterDetailModel>();
  final currentPageIndex = 0.obs;
  final isChapterComplete = false.obs;
  final isReadMode = true.obs;

  int get totalPages => chapter.value?.pageCount ?? 0;
  int get currentPageNumber => currentPageIndex.value + 1;
  bool get canGoBack => currentPageIndex.value > 0;
  bool get isLastPage => totalPages > 0 && currentPageIndex.value >= totalPages - 1;
  int get progressPercent =>
      totalPages > 0 ? (((currentPageIndex.value + 1) / totalPages) * 100).round() : 0;

  ChapterPageModel? get currentPage {
    final pages = chapter.value?.pages;
    if (pages == null || pages.isEmpty) return null;
    if (currentPageIndex.value < 0 || currentPageIndex.value >= pages.length) {
      return null;
    }
    return pages[currentPageIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['storyId'] != null && args['storyId'].toString().isNotEmpty) {
        storyId = args['storyId'].toString();
      }
      if (args['chapterId'] != null && args['chapterId'].toString().isNotEmpty) {
        chapterId = args['chapterId'].toString();
      }
    }
    loadChapter();
  }

  Future<void> loadChapter() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';
    isChapterComplete.value = false;

    try {
      final detail = await _repository.getChapterDetail(
        storyId: storyId,
        chapterId: chapterId,
      );
      chapter.value = detail;
      currentPageIndex.value = 0;
      isLoading.value = false;
      _reportProgress();
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> onNextPage() async {
    final page = currentPage;
    if (page != null && page.hasCheckpoint) {
      onCheckpointTriggered(page);
    }

    if (isLastPage) {
      await completeChapter();
    } else {
      currentPageIndex.value++;
      _reportProgress();
    }
  }

  void onPreviousPage() {
    if (canGoBack) {
      currentPageIndex.value--;
      _reportProgress();
    }
  }

  Future<void> _reportProgress() async {
    if (chapter.value == null) return;
    try {
      await _repository.updateReadingProgress(
        storyId: storyId,
        chapterId: chapterId,
        pageNumber: currentPageNumber,
        percent: progressPercent,
        mode: 'read',
      );
    } catch (_) {
      // Progress reporting shouldn't crash the reader UI
    }
  }

  Future<void> completeChapter() async {
    try {
      await _repository.completeChapter(
        storyId: storyId,
        chapterId: chapterId,
      );
    } catch (_) {
      // Complete call failure shouldn't block showing completion UI
    }
    isChapterComplete.value = true;
  }

  void onToggleMode(bool readSelected) {
    if (!readSelected) {
      // Switch to listen mode (T-APP-013)
      Get.toNamed(
        Routes.STORY_LISTENING,
        arguments: {
          'storyId': storyId,
          'chapterId': chapterId,
        },
      );
    }
  }

  void onCheckpointTriggered(ChapterPageModel page) {
    // Hook for T-APP-014 checkpoint questions between pages.
    // If a checkpoint route is active, push here; no-op until 014 exists.
  }

  void onTakeQuiz() {
    Get.toNamed(
      Routes.CHAPTER_QUIZ,
      arguments: {
        'storyId': storyId,
        'chapterId': chapterId,
      },
    );
  }

  void onBackToHome() {
    Get.offAllNamed(Routes.MAIN_PAGE);
  }

  void onBackTap() {
    Get.back();
  }
}
