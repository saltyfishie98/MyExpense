import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static void setup({ColorScheme? light, ColorScheme? dark}) {
    late ColorScheme lightScheme;
    late ColorScheme darkScheme;

    if (light != null && dark != null) {
      lightScheme = light
          .copyWith(
            brightness: Brightness.light,
          )
          .harmonized();

      darkScheme = dark
          .copyWith(
            brightness: Brightness.dark,
          )
          .harmonized();

      AppTheme.light = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: lightScheme,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: lightScheme.secondaryContainer,
            shadow: Colors.grey.shade400,
            accent: lightScheme.surfaceVariant,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade400,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: darkScheme.secondaryContainer,
            shadow: Colors.black,
            accent: darkScheme.secondaryContainer,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade400,
          ),
        ],
      );
      //
    } else {
      const swatchColor = Color.fromRGBO(134, 134, 127, 1);

      Map<int, Color> swatch = {
        50: swatchColor.withOpacity(.1),
        100: swatchColor.withOpacity(.2),
        200: swatchColor.withOpacity(.3),
        300: swatchColor.withOpacity(.4),
        400: swatchColor.withOpacity(.5),
        500: swatchColor.withOpacity(.6),
        600: swatchColor.withOpacity(.7),
        700: swatchColor.withOpacity(.8),
        800: swatchColor.withOpacity(.9),
        900: swatchColor.withOpacity(1),
      };

      final primaryColor = MaterialColor(swatchColor.value, swatch);

      lightScheme = ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
      ).copyWith(background: Colors.grey.shade300).harmonized();

      darkScheme = ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(background: Colors.grey.shade900).harmonized();

      AppTheme.light = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: lightScheme,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: lightScheme.primary,
            shadow: Colors.grey.shade400,
            accent: lightScheme.primary,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade400,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: Colors.grey.shade700,
            shadow: Colors.black,
            accent: darkScheme.primary,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade400,
          ),
        ],
      );
    }
  }

  static late ThemeData dark;
  static late ThemeData light;

  static const bool _useMaterial3 = true;
}

@immutable
class ElementThemes extends ThemeExtension<ElementThemes> {
  const ElementThemes({
    required this.card,
    required this.shadow,
    required this.accent,
    required this.subsurface,
    required this.h3Color,
  });

  final Color card;
  final Color shadow;
  final Color accent;
  final Color subsurface;
  final Color h3Color;

  @override
  ThemeExtension<ElementThemes> copyWith({
    Color? card,
    Color? shadow,
    Color? accent,
    Color? subsurface,
    Color? h3Color,
  }) {
    return ElementThemes(
      card: card ?? this.card,
      shadow: shadow ?? this.shadow,
      accent: accent ?? this.accent,
      subsurface: subsurface ?? this.subsurface,
      h3Color: h3Color ?? this.h3Color,
    );
  }

  @override
  ThemeExtension<ElementThemes> lerp(
      ThemeExtension<ElementThemes>? other, double t) {
    if (other is! ElementThemes) {
      return this;
    }

    return ElementThemes(
      card: Color.lerp(card, other.card, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      subsurface: Color.lerp(subsurface, other.subsurface, t)!,
      h3Color: Color.lerp(h3Color, other.h3Color, t)!,
    );
  }
}
