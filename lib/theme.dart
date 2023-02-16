import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static void setup({ColorScheme? light, ColorScheme? dark}) {
    if (light != null && dark != null) {
      final modifiedLight = light.harmonized().copyWith(
            background: Colors.grey[300],
          );

      AppTheme.light = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: modifiedLight,
      );
      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: dark.harmonized(),
      );
    } else {
      AppTheme.light = ThemeData(useMaterial3: _useMaterial3);
      AppTheme.dark = ThemeData(useMaterial3: _useMaterial3);
    }
  }

  static late ThemeData dark;
  static late ThemeData light;

  static const bool _useMaterial3 = true;
}
