import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/buddy_character.dart';
import '../widgets/read_story_button.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_section.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  static const String _story =
      'Once upon a time, a clever little robot named Peblo lost his '
      'yellow touring bag in the Whispering Woods…';

  late final ConfettiController _confetti;
  AudioState _lastAudio = AudioState.idle;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  BuddyMood _moodFor(AudioState audio, QuizProvider quiz) {
    if (quiz.isCorrect) return BuddyMood.happy;
    if (audio == AudioState.loading) return BuddyMood.thinking;
    if (audio == AudioState.playing) return BuddyMood.talking;
    return BuddyMood.idle;
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final quiz = context.watch<QuizProvider>();

    // Audio just finished → reveal the quiz, but only if it isn't already
    // showing (so replaying the story mid-quiz doesn't reset back to Q1).
    if (audio.state == AudioState.done && _lastAudio != AudioState.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.read<QuizProvider>().isVisible) {
          context.read<QuizProvider>().reveal();
        }
      });
    }
    _lastAudio = audio.state;

    // Correct answer → celebrate once.
    if (quiz.isCorrect && !_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
    }
    if (!quiz.isCorrect) _celebrated = false;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.skyTop, AppColors.skyMid, AppColors.cream],
                stops: [0.0, 0.35, 0.75],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 22),
                  Center(
                    child: BuddyCharacter(
                      mood: _moodFor(audio.state, quiz),
                      size: 180,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StoryCard(text: _story, audioState: audio.state),
                  const SizedBox(height: 24),
                  if (audio.hasError)
                    _errorCard(context)
                  else
                    Center(
                      child: ReadStoryButton(
                        state: audio.state,
                        onTap: () =>
                            context.read<AudioProvider>().speak(_story),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Smooth reveal of the quiz once it becomes visible.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: quiz.isVisible
                        ? const QuizSection(key: ValueKey('quiz'))
                        : const SizedBox(
                            width: double.infinity,
                            key: ValueKey('empty'),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti bursts from the top-centre.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 18,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.25,
              colors: const [
                AppColors.sunStart,
                AppColors.correct,
                AppColors.buddyBody,
                AppColors.wrong,
                Color(0xFF8E7CFF),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📖', style: TextStyle(fontSize: 26)),
        const SizedBox(width: 8),
        const Text(
          'Story Buddy',
          style: TextStyle(
            fontFamily: AppText.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _errorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.wrong.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.wrong.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.wrong, size: 40),
          const SizedBox(height: 10),
          const Text(
            "Oops! Peblo couldn't speak right now.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please check your sound and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              context.read<AudioProvider>().retry();
              context.read<AudioProvider>().speak(_story);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.wrong,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('Try Again',
                      style: TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
