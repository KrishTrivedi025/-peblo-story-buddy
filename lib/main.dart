import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/story_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PebloApp());
}

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Two separate notifiers keep audio and quiz concerns independent, so a
    // change in one never forces the other's widgets to rebuild.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'Peblo Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: AppText.fontFamily,
          scaffoldBackgroundColor: AppColors.cream,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.buddyBody),
          useMaterial3: true,
        ),
        home: const StoryScreen(),
      ),
    );
  }
}
