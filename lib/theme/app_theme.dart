import 'package:flutter/material.dart';

/// Central design tokens for the Peblo Story Buddy.
/// Keeping colours, fonts and shadows in one place keeps the UI
/// consistent and easy to tweak.
class AppColors {
  // Peblo exact brand colours (sampled from mypeblo.com)
  static const primary = Color(0xFF7C3AED);       // vibrant purple — headings
  static const primaryDark = Color(0xFF5B21B6);   // deep purple — dark states
  static const primaryLight = Color(0xFF9F67F5);  // lighter purple — buddy highlight
  static const primarySurface = Color(0xFFF5F0FF); // barely-purple white — card bg

  // Background: pure white with a very subtle lavender blush at top
  static const skyTop = Color(0xFFEEE6FF);
  static const skyMid = Color(0xFFF7F3FF);
  static const cream = Color(0xFFFFFFFF);

  // "Notify Me" style button — amber/golden yellow with dark purple text
  static const btnAmber = Color(0xFFF5A623);
  static const btnAmberDark = Color(0xFFE09010);
  static const btnText = Color(0xFF7C3AED);

  // Keep sunStart/sunEnd pointing to amber so existing widgets compile
  static const sunStart = Color(0xFFF5A623);
  static const sunEnd = Color(0xFFE09010);

  // Buddy robot — Peblo purple (matches the purple mascot on their site)
  static const buddyBody = Color(0xFF9F67F5);
  static const buddyBodyDark = Color(0xFF7C3AED);
  static const buddyBelly = Color(0xFFF5F0FF);

  // Feedback
  static const correct = Color(0xFF06D6A0);
  static const correctDark = Color(0xFF04A57C);
  static const wrong = Color(0xFFEF476F);
  static const wrongDark = Color(0xFFC9304F);

  // Text & surfaces
  static const ink = Color(0xFF1A0533);
  static const inkSoft = Color(0xFF6B4F8A);
  static const card = Color(0xFFFFFFFF);

  // Quiz option accents — order matches the quiz options: Red, Green, Blue, Yellow
  static const optionAccents = <Color>[
    Color(0xFFEF4444),  // red
    Color(0xFF22C55E),  // green
    Color(0xFF3B82F6),  // blue
    Color(0xFFEAB308),  // yellow
    Color(0xFF9F67F5),  // purple fallback for 5th+ options
  ];
}

class AppText {
  static const fontFamily = 'Fredoka';

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    color: AppColors.ink,
    letterSpacing: 0.2,
  );

  static const TextStyle story = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle question = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.35,
    color: AppColors.ink,
  );

  static const TextStyle option = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    color: AppColors.ink,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: Colors.white,
    letterSpacing: 0.3,
  );
}

class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.10),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.btnAmber.withValues(alpha: 0.45),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
