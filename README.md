# Peblo Story Buddy 📖

This is my submission for the Peblo Flutter Intern Challenge. The task was to build a single-screen "AI Story Buddy & Quiz" app for kids — something that reads a short story out loud, then tests the child with a quiz after the audio finishes.

I built this fully in Flutter over a few days, handling everything from the TTS integration to the custom character animation to the quiz transitions. Here's a walkthrough of everything.

---

## What the app actually does

When you open the app, you see a purple robot character called Peblo standing above a story card. The story is about how Peblo the robot lost his yellow touring bag in the Whispering Woods.

You tap **"Read Me a Story"** and the device reads the story aloud using the built-in text-to-speech engine. While it's reading, Peblo's mouth animates like he's actually talking. Once the audio finishes, the quiz slides up smoothly from below.

The quiz has two questions. First one asks what colour Peblo's lost bag was (answer: Yellow). After you get it right, a **"Next Question"** button appears. You tap it and the question slides out to the left while the second question slides in from the right. Second question asks for the robot's name (answer: Peblo).

If you tap a wrong answer the whole quiz card shakes and the phone vibrates. You can try again as many times as you need.

When you finally get the last question right, confetti bursts across the screen, Peblo goes into his happy dancing mode, and a **"Hooray! You got it!"** banner shows up with a 5-second circular countdown. After it hits zero the banner swaps to a **"Move to Next Story"** button which resets everything back to the beginning.

---

## Folder structure

```
lib/
├── main.dart                  # App entry, MultiProvider setup
├── models/
│   └── quiz_model.dart        # QuizQuestion model with fromJson
├── providers/
│   ├── audio_provider.dart    # TTS state machine
│   └── quiz_provider.dart     # Quiz logic, two questions
├── screens/
│   └── story_screen.dart      # The single screen
├── theme/
│   └── app_theme.dart         # Colors, text styles, shadows
└── widgets/
    ├── buddy_character.dart   # Custom painted character, 4 moods
    ├── quiz_option_button.dart
    ├── quiz_section.dart      # Slide transitions, countdown
    ├── read_story_button.dart
    └── story_card.dart
```

---

## How to run it

You'll need Flutter 3.x installed and either a physical Android device or an emulator.

```bash
git clone https://github.com/KrishTrivedi025/-peblo-story-buddy.git
cd -peblo-story-buddy
flutter pub get
flutter run
```

If you're on a real device make sure USB debugging is on and the device is connected. The TTS works offline since it uses the device's native speech engine — no API keys needed.

One thing to note: the first time Gradle builds it takes a few minutes because it has to download everything. After that it's fast.

---

## Tech decisions I made and why

**Flutter TTS over any API** — The challenge said TTS narration. I used the `flutter_tts` package which taps into the device's built-in engine. This means it works offline, there's no latency from a network call, and kids on slow connections still get the full experience. I set the speech rate to 0.45 and pitch to 1.1 so it sounds friendly and clear rather than robotic.

**Provider for state** — The app has two independent pieces of state: audio playback and quiz progress. I split them into `AudioProvider` and `QuizProvider` so neither one knows about the other. The story screen watches both and coordinates — when audio hits `done`, it tells the quiz to reveal itself.

**Data-driven quiz** — The quiz question and options are loaded from a JSON map inside the provider. The rendering code doesn't care how many options there are. You can change the question, add more options, or swap in completely different content and the UI handles it automatically. The widget tests cover 3-option, 4-option, and 5-option configurations to prove this.

**Custom painted character** — I drew Peblo entirely with Flutter's `CustomPainter` and `Canvas` API. No image assets. The head uses a radial gradient to give it that 3D rounded look. Eyes have a white sclera, deep purple iris, pupil, and two shine dots. He blinks randomly every 2-5 seconds. There are four moods: idle (gentle breathing bob), thinking (one eyebrow raised), talking (mouth opens and closes in sync with TTS), and happy (bouncing, cheeks flushed, arms raised, amber heart on belly, sparkle stars around him).

**Slide transition between questions** — I used `AnimatedSwitcher` with a custom `transitionBuilder` that slides the outgoing question to the left while the incoming one comes in from the right, with a fade on both. Getting this right was tricky because `ClipRect` was clipping the button shadows and making them look like hard boxes. I solved it with a custom `CustomClipper` that only clips horizontally, leaving the vertical axis open so shadows render naturally.

---

## Challenge requirements checklist

- ✅ Single screen Flutter app
- ✅ TTS narration with `flutter_tts` — idle / loading / playing / done / error states all handled
- ✅ Data-driven quiz from JSON — works with any number of options, no code change needed
- ✅ Wrong answer triggers card shake animation + haptic feedback, retry allowed
- ✅ Correct answer triggers confetti burst + buddy happy state + success banner
- ✅ Quiz reveals only after audio finishes, with smooth slide-up animation
- ✅ State management with Provider (`ChangeNotifier` + `context.watch` / `context.read`)
- ✅ Widget tests for data-driven quiz (3, 4, and 5 option configurations)

---

## Dependencies

```yaml
flutter_tts: ^4.2.0      # Text-to-speech narration
provider: ^6.1.2          # State management
confetti: ^0.7.0          # Celebration animation on correct answer
```

Font used is **Fredoka** (bundled locally in assets/fonts — no Google Fonts network dependency).

---

## A few things I'd add with more time

The character is drawn in code right now. With more time I'd swap in a proper Lottie animation file so the movements look more fluid. I'd also add more stories — the architecture is set up for it, you'd just add more entries to the questions list and update the story text. Sound effects for button taps would be a nice touch too.

---

Built by Krrish Trivedi for the Peblo Flutter Intern Challenge.
