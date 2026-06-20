import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_option_button.dart';

class QuizSection extends StatefulWidget {
  const QuizSection({super.key});

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection>
    with TickerProviderStateMixin {
  late final AnimationController _reveal;
  late final AnimationController _shake;
  QuizState _lastState = QuizState.visible;

  // Tracks which question index is currently displayed in the AnimatedSwitcher.
  int _displayedIndex = 0;

  // Final-question hooray countdown.
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _showMoveButton = false;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _reveal.dispose();
    _shake.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _onWrong() async {
    _shake.forward(from: 0);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 850));
    if (mounted) context.read<QuizProvider>().resetWrong();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 5;
      _showMoveButton = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          _countdownTimer = null;
          _showMoveButton = true;
        }
      });
    });
  }

  // Called when user taps "Next Question". Both state changes are batched
  // into one frame so AnimatedSwitcher sees a clean key swap.
  void _goToNextQuestion() {
    setState(() => _displayedIndex += 1);
    context.read<QuizProvider>().nextQuestion();
    // _reveal stays at 1.0 — the incoming question uses the slide animation
    // from AnimatedSwitcher instead of the stagger reveal.
  }

  void _resetAll() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    context.read<QuizProvider>().reset();
    context.read<AudioProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (quiz.state == QuizState.wrong && _lastState != QuizState.wrong) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onWrong());
    }

    // Start the 5-second countdown only when the LAST question is newly answered correctly.
    if (quiz.isCorrect &&
        quiz.isLastQuestion &&
        _lastState != QuizState.correct &&
        _countdownTimer == null &&
        !_showMoveButton) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) { if (mounted) _startCountdown(); });
    }

    _lastState = quiz.state;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx = math.sin(_shake.value * math.pi * 4) * 12;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header — matches story card icon style.
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Quiz Time!',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Clips only horizontally so the slide stays within the card,
            // but lets the button shadow bleed downward naturally.
            ClipRect(
              clipper: const _HorizontalClipper(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final isIncoming =
                      child.key == ValueKey(_displayedIndex);
                  return AnimatedBuilder(
                    animation: animation,
                    child: child,
                    builder: (ctx, c) {
                      final w = MediaQuery.of(ctx).size.width;
                      // Incoming: starts off-right, ends at center.
                      // Outgoing: starts at center, ends off-left.
                      final dx = isIncoming
                          ? (1.0 - animation.value) * w
                          : -(1.0 - animation.value) * w;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: FadeTransition(opacity: animation, child: c),
                      );
                    },
                  );
                },
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: _buildQuestionBody(
                    quiz, key: ValueKey(_displayedIndex)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBody(QuizProvider quiz, {required Key key}) {
    final q = quiz.question;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.question,
            style: AppText.question.copyWith(color: AppColors.btnAmber)),
        const SizedBox(height: 20),

        // Data-driven options — works for any number.
        ...List.generate(q.options.length, (i) {
          final option = q.options[i];
          final accent =
              AppColors.optionAccents[i % AppColors.optionAccents.length];
          final selected = quiz.selectedAnswer == option;
          return Padding(
            padding:
                EdgeInsets.only(bottom: i == q.options.length - 1 ? 0 : 12),
            child: _staggeredItem(
              index: i,
              count: q.options.length,
              child: QuizOptionButton(
                label: option,
                accent: accent,
                isSelected: selected,
                showCorrect: quiz.isCorrect && selected,
                showWrong: quiz.isWrong && selected,
                locked: quiz.isCorrect,
                onTap: () =>
                    context.read<QuizProvider>().selectAnswer(option),
              ),
            ),
          );
        }),

        // Action area: nothing → Next Question button → Hooray/Move.
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: quiz.isCorrect
              ? Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: quiz.isLastQuestion
                      ? _buildFinalArea()
                      : _buildNextButton(),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  // ── "Next Question" button (shown after Q1 correct) ──────────────────────

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _goToNextQuestion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded,
                color: AppColors.btnAmber, size: 26),
            SizedBox(width: 10),
            Text(
              'Next Question',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.btnAmber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Final area: Hooray + countdown → "Move to Next Story" ────────────────

  Widget _buildFinalArea() {
    if (_showMoveButton) {
      return GestureDetector(
        onTap: _resetAll,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_rounded,
                  color: AppColors.btnAmber, size: 26),
              SizedBox(width: 10),
              Text(
                'Move to Next Story',
                style: TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.btnAmber,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Hooray banner with circular countdown.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded,
              color: AppColors.btnAmber, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hooray! You got it!',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.btnAmber,
              ),
            ),
          ),
          // Small circular countdown in the banner.
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _countdown / 5.0,
                  strokeWidth: 3,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.btnAmber),
                  backgroundColor:
                      AppColors.primaryLight.withValues(alpha: 0.3),
                ),
                Text(
                  '$_countdown',
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.btnAmber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Staggered slide-up reveal for initial quiz appearance ─────────────────

  Widget _staggeredItem({
    required int index,
    required int count,
    required Widget child,
  }) {
    final start = (index / (count + 1)) * 0.6;
    final anim = CurvedAnimation(
      parent: _reveal,
      curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, c) => Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 24),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// Clips only the horizontal axis so sliding questions stay within the card,
/// while leaving the vertical axis open for button shadows to render fully.
class _HorizontalClipper extends CustomClipper<Rect> {
  const _HorizontalClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(-20, -200, size.width + 40, size.height + 400);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> old) => false;
}
