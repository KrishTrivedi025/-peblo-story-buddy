import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';

/// Styled to match Peblo's "Notify Me" CTA:
/// amber/golden pill, dark-purple bold text, springy press animation.
class ReadStoryButton extends StatefulWidget {
  final AudioState state;
  final VoidCallback onTap;

  const ReadStoryButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  State<ReadStoryButton> createState() => _ReadStoryButtonState();
}

class _ReadStoryButtonState extends State<ReadStoryButton> {
  bool _pressed = false;

  bool get _busy =>
      widget.state == AudioState.loading ||
      widget.state == AudioState.playing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: _busy ? null : (_) => setState(() => _pressed = false),
      onTapCancel: _busy ? null : () => setState(() => _pressed = false),
      onTap: _busy ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          decoration: BoxDecoration(
            color: _busy ? AppColors.primaryDark : AppColors.primary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: _pressed
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(width: 10),
              Text(
                _label(),
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.btnAmber,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (widget.state) {
      case AudioState.loading:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.btnAmber),
          ),
        );
      case AudioState.playing:
        return const Icon(Icons.graphic_eq_rounded,
            color: AppColors.btnAmber, size: 26);
      default:
        return const Icon(Icons.auto_stories_rounded,
            color: AppColors.btnAmber, size: 26);
    }
  }

  String _label() {
    switch (widget.state) {
      case AudioState.loading:
        return 'Waking up Pip…';
      case AudioState.playing:
        return 'Reading…';
      case AudioState.done:
        return 'Read it Again';
      default:
        return 'Read Me a Story';
    }
  }
}
