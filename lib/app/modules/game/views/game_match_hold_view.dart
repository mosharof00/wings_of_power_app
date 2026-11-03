import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wings_of_power_app/app/data/models/game_match.dart';
import '../controllers/game_play_controller.dart';
import 'widgets/game_countdown_overlay.dart';
import 'widgets/game_free_text_board.dart';
import 'widgets/game_kindness_celebration_dialog.dart';
import 'widgets/game_quiz_board.dart';
import 'widgets/game_round_intro_card.dart';
import 'widgets/game_vs_pills.dart';
import 'widgets/game_waiting_overlay.dart';
import 'single_shot_court_view.dart';
import 'round_complete_view.dart';

class GameMatchHoldView extends StatefulWidget {
  const GameMatchHoldView({
    super.key,
    required this.snapshot,
    this.currentUserId,
    this.currentUserNickname,
  });

  final GameMatchSnapshot snapshot;
  final String? currentUserId;
  final String? currentUserNickname;

  @override
  State<GameMatchHoldView> createState() => _GameMatchHoldViewState();
}

class _GameMatchHoldViewState extends State<GameMatchHoldView> {
  late GamePlayController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      GamePlayController(
        initialSnapshot: widget.snapshot,
        currentUserId: widget.currentUserId,
        currentUserNickname: widget.currentUserNickname,
      ),
      tag: widget.snapshot.matchId,
    );
  }

  @override
  void dispose() {
    Get.delete<GamePlayController>(tag: widget.snapshot.matchId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final phase = _controller.phase.value;
        final hasQuestion = _controller.currentQuestion.value != null;

        if (phase == GamePhase.roundIntro) {
          return GameRoundIntroCard(
            introEvent: _controller.currentIntro.value,
            onOpenQuiz: _controller.onOpenQuizTap,
          );
        }

        if (phase == GamePhase.shootout) {
          return SingleShotCourtView(controller: _controller);
        }

        if (phase == GamePhase.roundComplete) {
          return RoundCompleteView(controller: _controller);
        }

        if ((phase == GamePhase.question || phase == GamePhase.complete) &&
            hasQuestion) {
          if (_controller.isQ2Defense) {
            return _buildQ2DefenseScreen(context);
          }
          return _buildQuestionScreen(context);
        }

        // Hold or Countdown over Hold
        return Stack(
          children: [
            _buildHoldScreen(context),
            if (phase == GamePhase.countdown)
              GameCountdownOverlay(
                countdownValue: _controller.countdownValue.value,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildQuestionScreen(BuildContext context) {
    final q = _controller.currentQuestion.value!;
    final subPhase = _controller.questionSubPhase.value;
    final isYouBuzzed = subPhase == QuestionSubPhase.buzzedYou;
    final waiting = _controller.waiting.value;
    final timerStr = _controller.timerString.value;
    final selectedIdx = _controller.selectedOptionIndex.value;
    final result = _controller.answerResult.value;
    final canPass = _controller.canPass;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7822B7),
            Color(0xFF5D1D9B),
            Color(0xFF4C157E),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Close 'x' button
                  GestureDetector(
                    onTap: () => _controller.onLeaveTap(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE86726),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),

                  // Center Title
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _controller.currentRoundSubtitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _controller.currentRoundTitle,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Power bolt button
                  GestureDetector(
                    onTap: () => _controller.onPowersTap(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE86726),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Vs Pills with scores
            GameVsPills(
              teamALabel: _controller.getTeamLabel(0),
              teamAScore: _controller.getTeamScore(0),
              teamBLabel: _controller.getTeamLabel(1),
              teamBScore: _controller.getTeamScore(1),
              isTeamAActive: _controller.isTeamActive(0),
              isTeamBActive: _controller.isTeamActive(1),
            ),
            SizedBox(height: 16.h),

            // Quiz Board Card
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: GameQuizBoard(
                  question: q,
                  subPhase: subPhase,
                  timerString: timerStr,
                  isYouBuzzed: isYouBuzzed,
                  waitingInfo: waiting,
                  selectedOptionIndex: selectedIdx,
                  answerResult: result,
                  canPass: canPass,
                  onBuzzTap: _controller.onBuzzTap,
                  onOptionTap: _controller.onOptionTap,
                  onPassTap: _controller.onPassTap,
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQ2DefenseScreen(BuildContext context) {
    final q = _controller.currentQuestion.value!;
    final timerStr = _controller.timerString.value;
    final youNick = widget.currentUserNickname ??
        _controller.currentUserNickname ??
        'Alex';
    final teamLabel = _controller.getTeamLabel(0);
    final avatarUrl = _controller.snapshot.value.allParticipants
        .firstWhereOrNull((p) =>
            p.userId == widget.currentUserId ||
            p.id == _controller.youParticipantId)
        ?.avatarUrl;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7822B7),
            Color(0xFF5D1D9B),
            Color(0xFF4C157E),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 10.h),

                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      // Close 'x' button
                      GestureDetector(
                        onTap: () => _controller.onLeaveTap(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE86726),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),

                      // Center Title
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Round 2',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Defense Round',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Power bolt button
                      GestureDetector(
                        onTap: () => _controller.onPowersTap(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE86726),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Vs Pills with kindness coins (245 Vs 210)
                GameVsPills(
                  teamALabel: _controller.getTeamLabel(0),
                  teamAScore: _controller.getTeamKindness(0),
                  teamBLabel: _controller.getTeamLabel(1),
                  teamBScore: _controller.getTeamKindness(1),
                  isTeamAActive: true,
                  isTeamBActive: false,
                ),
                SizedBox(height: 16.h),

                // Free Text Board Card
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    child: GameFreeTextBoard(
                      question: q,
                      timerString: timerStr,
                      nickname: youNick,
                      teamLabel: teamLabel,
                      avatarUrl: avatarUrl,
                      textController: _controller.freeTextController,
                      canSubmit: _controller.canSubmitFreeText,
                      isSubmitted: _controller.isFreeTextSubmitted.value,
                      isSubmitting: _controller.isSubmittingAnswer.value,
                      onTextChanged: _controller.onFreeTextChanged,
                      onSubmit: _controller.onSubmitFreeText,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),

            // Waiting overlay
            if (_controller.isWaitingOthers.value &&
                !_controller.showKindnessCelebration.value)
              const GameWaitingOverlay(),

            // Kindness points celebration modal
            if (_controller.showKindnessCelebration.value)
              GameKindnessCelebrationDialog(
                points: 50,
                onPlayTheShoot: _controller.onPlayTheShootTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldScreen(BuildContext context) {
    final you = _findYouParticipant();
    final opponent = _findOpponentParticipant(you);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7822B7),
            Color(0xFF5D1D9B),
            Color(0xFF4C157E),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _controller.onLeaveTap(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C1D95),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFFFD54F),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sports_basketball,
                          color: const Color(0xFFFFD54F),
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'PRACTICE ARENA',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 40.w),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Match Ready Title
            Text(
              'Match Ready',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD54F),
                shadows: const [
                  Shadow(
                    color: Color(0xFF3B0764),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Mode: ${_controller.snapshot.value.mode}  •  Phase: ${_controller.snapshot.value.phase}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 12.h),

            // Countdown Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE86726),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44E86726),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Starting in ${_controller.secondsLeft.value}s',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Matchup Area (You vs Opponent)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _ParticipantCard(
                        isYou: true,
                        participant: you,
                        fallbackNickname: widget.currentUserNickname ?? 'Alex',
                        fallbackHero: 'Faith',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD54F),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _ParticipantCard(
                        isYou: false,
                        participant: opponent,
                        fallbackNickname: 'Practice Bot',
                        fallbackHero: 'Harold',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Match Details & Status
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Match ID: ${_controller.snapshot.value.matchId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Leave Match Action Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => _controller.onLeaveTap(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                  child: Text(
                    'Leave Match',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  GameMatchParticipant _findYouParticipant() {
    final youId = widget.currentUserId;
    final all = _controller.snapshot.value.allParticipants;
    final youFromList = all.firstWhereOrNull((p) => p.userId == youId);
    if (youFromList != null) return youFromList;

    final firstNonBot = all.firstWhereOrNull((p) => !p.isBot);
    if (firstNonBot != null) return firstNonBot;

    return GameMatchParticipant(
      userId: youId ?? 'you',
      nickname: widget.currentUserNickname ?? 'Alex',
      avatarUrl: 'assets/images/avatar_01.png',
      jerseyNumber: _controller.snapshot.value.you?.jerseyNumber ?? 1,
      isBot: false,
    );
  }

  GameMatchParticipant _findOpponentParticipant(GameMatchParticipant you) {
    return _controller.snapshot.value.botOrOpponent(you.userId);
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.isYou,
    required this.participant,
    required this.fallbackNickname,
    required this.fallbackHero,
  });

  final bool isYou;
  final GameMatchParticipant participant;
  final String fallbackNickname;
  final String fallbackHero;

  @override
  Widget build(BuildContext context) {
    final nickname = participant.nickname ?? fallbackNickname;
    final isBot = participant.isBot;
    final jersey = participant.jerseyNumber ?? (isYou ? 1 : 2);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isYou ? Colors.white : const Color(0xFFFFF6EB),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isYou ? const Color(0xFFFFD54F) : const Color(0xFFFFDFC8),
          width: 2.w,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isYou ? const Color(0xFFE86726) : const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isYou ? 'YOU' : (isBot ? 'BOT' : 'OPPONENT'),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isYou
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFD1D5DB),
                width: 2.5.w,
              ),
            ),
            child: ClipOval(
              child: isBot
                  ? Container(
                      color: const Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 38.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  : Image.asset(
                      participant.avatarUrl ?? 'assets/images/avatar_01.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 36,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Jersey #$jersey',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            participant.heroId != null
                ? 'Hero: ${participant.heroId}'
                : (isBot ? 'Bot Seat' : 'Power Ready'),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE86726),
            ),
          ),
        ],
      ),
    );
  }
}
