import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';

/// The card holding the story text. While Pip is talking we draw a row of
/// bouncing bars (a tiny "equaliser") so the child can see he's speaking.
class StoryCard extends StatelessWidget {
  final String text;
  final AudioState audioState;

  const StoryCard({
    super.key,
    required this.text,
    required this.audioState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 1.5),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Peblo's Story",
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primary,
                  )),
              const Spacer(),
              if (audioState == AudioState.playing) const _SoundBars(),
            ],
          ),
          const SizedBox(height: 16),
          Text(text, style: AppText.story),
        ],
      ),
    );
  }
}

class _SoundBars extends StatefulWidget {
  const _SoundBars();

  @override
  State<_SoundBars> createState() => _SoundBarsState();
}

class _SoundBarsState extends State<_SoundBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final phase = (_c.value + i * 0.22) % 1.0;
            final h = 6 + (phase) * 16;
            return Container(
              width: 4,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.sunEnd,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
