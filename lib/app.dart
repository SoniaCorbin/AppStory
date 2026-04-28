import 'package:flutter/material.dart';
import 'core/routing/routes.dart';
import 'core/theme/story_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/shell/shell_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class StoryBlocksApp extends StatelessWidget {
  const StoryBlocksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryBlocks',
      debugShowCheckedModeBanner: false,
      theme: buildStoryTheme(),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.onboarding: (_) => const OnboardingScreen(),
        Routes.shell: (_) => const ShellScreen(),
      },
    );
  }
}