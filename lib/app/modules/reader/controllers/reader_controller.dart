import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';
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

  // Audio Playback Observables
  final isAudioPlaying = false.obs;
  final audioPosition = Duration.zero.obs;
  final audioDuration = const Duration(minutes: 12, seconds: 48).obs;
  final isAudioLoading = false.obs;

  AudioPlayer? _audioPlayer;
  Timer? _playbackTimer;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  bool _useTimerFallback = false;

  int get totalPages => chapter.value?.pageCount ?? 0;
  int get currentPageNumber => currentPageIndex.value + 1;
  bool get canGoBack => currentPageIndex.value > 0;
  bool get isLastPage =>
      totalPages > 0 && currentPageIndex.value >= totalPages - 1;
  int get progressPercent => totalPages > 0
      ? (((currentPageIndex.value + 1) / totalPages) * 100).round()
      : 0;

  int get audioProgressPercent {
    final total = audioDuration.value.inMilliseconds;
    if (total <= 0) return 0;
    final current = audioPosition.value.inMilliseconds;
    return ((current / total) * 100).clamp(0, 100).round();
  }

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
      if (args['chapterId'] != null &&
          args['chapterId'].toString().isNotEmpty) {
        chapterId = args['chapterId'].toString();
      }
      if (args['mode'] == 'listen' || args['listen'] == true) {
        isReadMode.value = false;
      }
      if (args['initialPositionSeconds'] != null) {
        final sec =
            int.tryParse(args['initialPositionSeconds'].toString()) ?? 0;
        audioPosition.value = Duration(seconds: sec);
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

      await initAudio();

      if (!isReadMode.value) {
        playAudio();
      }

      _reportProgress();
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> initAudio() async {
    final detail = chapter.value;
    if (detail?.durationMs != null && detail!.durationMs! > 0) {
      audioDuration.value = Duration(milliseconds: detail.durationMs!);
    } else {
      audioDuration.value = const Duration(minutes: 12, seconds: 48);
    }

    final url = detail?.audioUrl;
    if (AppConfig.useMocks || url == null || url.isEmpty || kIsWeb) {
      _useTimerFallback = true;
      return;
    }

    try {
      _audioPlayer ??= AudioPlayer();
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();

      _playerStateSubscription =
          _audioPlayer!.playerStateStream.listen((state) {
        isAudioPlaying.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          onAudioCompleted();
        }
      });

      _positionSubscription = _audioPlayer!.positionStream.listen((pos) {
        if (!_useTimerFallback) {
          audioPosition.value = pos;
        }
      });

      _durationSubscription = _audioPlayer!.durationStream.listen((dur) {
        if (dur != null && dur > Duration.zero && !_useTimerFallback) {
          audioDuration.value = dur;
        }
      });

      await _audioPlayer!.setUrl(url);
    } catch (_) {
      // Audio network/platform unavailable, fallback to timer
      _useTimerFallback = true;
    }
  }

  Future<void> playAudio() async {
    if (isChapterComplete.value) return;

    if (_useTimerFallback || _audioPlayer == null) {
      isAudioPlaying.value = true;
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final nextSec = audioPosition.value.inSeconds + 1;
        if (nextSec >= audioDuration.value.inSeconds) {
          audioPosition.value = audioDuration.value;
          timer.cancel();
          isAudioPlaying.value = false;
          onAudioCompleted();
        } else {
          audioPosition.value = Duration(seconds: nextSec);
          if (nextSec % 10 == 0) {
            _reportProgress();
          }
        }
      });
      return;
    }

    try {
      await _audioPlayer!.play();
      isAudioPlaying.value = true;
    } catch (_) {
      _useTimerFallback = true;
      playAudio();
    }
  }

  Future<void> pauseAudio() async {
    _playbackTimer?.cancel();
    isAudioPlaying.value = false;

    if (_audioPlayer != null && !_useTimerFallback) {
      try {
        await _audioPlayer!.pause();
      } catch (_) {}
    }

    _reportProgress();
  }

  Future<void> togglePlayPause() async {
    if (isAudioPlaying.value) {
      await pauseAudio();
    } else {
      await playAudio();
    }
  }

  Future<void> seekAudio(Duration target) async {
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > audioDuration.value ? audioDuration.value : target);
    audioPosition.value = clamped;

    if (_audioPlayer != null && !_useTimerFallback) {
      try {
        await _audioPlayer!.seek(clamped);
      } catch (_) {}
    }

    _reportProgress();

    if (clamped >= audioDuration.value) {
      onAudioCompleted();
    }
  }

  void seekToFraction(double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    final targetMs = (audioDuration.value.inMilliseconds * clamped).round();
    seekAudio(Duration(milliseconds: targetMs));
  }

  void skipSeconds(int seconds) {
    final target = audioPosition.value + Duration(seconds: seconds);
    seekAudio(target);
  }

  void onPreviousTrackOrRewind() {
    if (audioPosition.value.inSeconds > 3) {
      seekAudio(Duration.zero);
    } else if (canGoBack) {
      onPreviousPage();
      seekAudio(Duration.zero);
    } else {
      seekAudio(Duration.zero);
    }
  }

  Future<void> onNextTrackOrSkip() async {
    if (!isLastPage) {
      currentPageIndex.value++;
      _reportProgress();
    } else {
      await completeChapter();
    }
  }

  Future<void> onAudioCompleted() async {
    _playbackTimer?.cancel();
    isAudioPlaying.value = false;
    audioPosition.value = audioDuration.value;
    await completeChapter();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
      final mode = isReadMode.value ? 'read' : 'listen';
      final percent =
          isReadMode.value ? progressPercent : audioProgressPercent;
      await _repository.updateReadingProgress(
        storyId: storyId,
        chapterId: chapterId,
        pageNumber: currentPageNumber,
        percent: percent,
        mode: mode,
      );
    } catch (_) {
      // Progress reporting shouldn't crash the reader UI
    }
  }

  Future<void> completeChapter() async {
    _playbackTimer?.cancel();
    isAudioPlaying.value = false;
    if (_audioPlayer != null && !_useTimerFallback) {
      try {
        await _audioPlayer!.stop();
      } catch (_) {}
    }

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
    if (isReadMode.value == readSelected) return;
    isReadMode.value = readSelected;
    if (readSelected) {
      pauseAudio();
    } else {
      playAudio();
    }
    _reportProgress();
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
    pauseAudio();
    Get.offAllNamed(Routes.MAIN_PAGE);
  }

  void onBackTap() {
    pauseAudio();
    Get.back();
  }

  @override
  void onClose() {
    _playbackTimer?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer?.dispose();
    super.onClose();
  }
}
