import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void applyTheme(ThemeMode mode) {
    ThemeData newThemeData;

    if (mode == ThemeMode.dark) {
      // Dark mode
      newThemeData = ThemeData.dark().copyWith(
        // Your dark mode theme data here
      );
    } else {
      // Light mode
      newThemeData = ThemeData.light().copyWith(
        // Your light mode theme data here
      );
    }

    themeData = newThemeData;
  }
}
