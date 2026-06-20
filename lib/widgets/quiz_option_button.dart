import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One tappable answer. Visuals are fully driven by props — the parent
/// decides the colour and which result state (if any) to show, so this
/// widget never needs to know the question or option count.
class QuizOptionButton extends StatefulWidget {
  final String label;
  final Color accent;
  final bool isSelected;
  final bool showCorrect;
  final bool showWrong;
  final bool locked;
  final VoidCallback onTap;

  const QuizOptionButton({
    super.key,
    required this.label,
    required this.accent,
    required this.isSelected,
    required this.showCorrect,
    required this.showWrong,
    required this.locked,
    required this.onTap,
  });

  @override
  State<QuizOptionButton> createState() => _QuizOptionButtonState();
}

class _QuizOptionButtonState extends State<QuizOptionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Color fill = AppColors.card;
    Color border = widget.accent;
    Color textColor = AppColors.ink;
    Widget? trailing;

    if (widget.showCorrect) {
      fill = AppColors.correct;
      border = AppColors.correctDark;
      textColor = Colors.white;
      trailing = const Icon(Icons.check_circle_rounded,
          color: Colors.white, size: 26);
    } else if (widget.showWrong) {
      fill = AppColors.wrong;
      border = AppColors.wrongDark;
      textColor = Colors.white;
      trailing = const Icon(Icons.cancel_rounded,
          color: Colors.white, size: 26);
    }

    return GestureDetector(
      onTapDown:
          widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked ? null : (_) => setState(() => _pressed = false),
      onTapCancel:
          widget.locked ? null : () => setState(() => _pressed = false),
      onTap: widget.locked ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Colour dot keeps it lively even before answering
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: (widget.showCorrect || widget.showWrong)
                      ? Colors.white
                      : widget.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppText.option.copyWith(color: textColor),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
