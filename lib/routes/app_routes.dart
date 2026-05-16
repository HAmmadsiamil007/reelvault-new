import 'package:flutter/material.dart';

import '../presentation/folder_selection_screen/folder_selection_screen.dart';
import '../presentation/reels_feed_screen/reels_feed_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String reelsFeedScreen = '/reels-feed-screen';
  static const String settingsScreen = '/settings-screen';
  static const String folderSelectionScreen = '/folder-selection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    reelsFeedScreen: (context) => const ReelsFeedScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    folderSelectionScreen: (context) => const FolderSelectionScreen(),
  };
}
