import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Default to Normal/Light Mode as requested
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    try {
      if (Hive.isBoxOpen('auth_box')) {
        final box = Hive.box('auth_box');
        final isDark = box.get('is_dark_theme') as bool?;
        if (isDark != null) {
          state = isDark ? ThemeMode.dark : ThemeMode.light;
        }
      }
    } catch (_) {}
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemePreference();
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _saveThemePreference();
  }

  void _saveThemePreference() async {
    try {
      if (Hive.isBoxOpen('auth_box')) {
        final box = Hive.box('auth_box');
        await box.put('is_dark_theme', state == ThemeMode.dark);
      }
    } catch (_) {}
  }
}




// ----------- old code version ------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
//   return ThemeModeNotifier();
// });

// class ThemeModeNotifier extends StateNotifier<ThemeMode> {
//   ThemeModeNotifier() : super(ThemeMode.dark); // Default to dark industrial theme

//   void toggleTheme() {
//     state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
//   }

//   void setTheme(ThemeMode mode) {
//     state = mode;
//   }
// }
