import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static void setup({ColorScheme? light, ColorScheme? dark}) {
    if (light != null && dark != null) {
      final lightScheme = light
          .copyWith(
            brightness: Brightness.light,
          )
          .harmonized();

      final darkScheme = dark
          .copyWith(
            brightness: Brightness.dark,
          )
          .harmonized();

      AppTheme.light = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: lightScheme,
        extensions: <ThemeExtension<dynamic>>[
          ElementColors(
            card: lightScheme.inversePrimary,
            shadow: Colors.grey.shade400,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          ElementColors(
            card: darkScheme.inversePrimary,
            shadow: Colors.black,
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

      final lightScheme = ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
      ).copyWith(background: Colors.grey.shade300).harmonized();

      final darkScheme = ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(background: Colors.grey.shade900).harmonized();

      AppTheme.light = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: lightScheme,
        extensions: <ThemeExtension<dynamic>>[
          ElementColors(
            card: lightScheme.primary,
            shadow: Colors.grey.shade400,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          ElementColors(
            card: Colors.grey.shade700,
            shadow: Colors.black,
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
class ElementColors extends ThemeExtension<ElementColors> {
  const ElementColors({
    required this.card,
    required this.shadow,
  });

  final Color card;
  final Color shadow;

  @override
  ThemeExtension<ElementColors> copyWith({Color? card, Color? shadow}) {
    return ElementColors(
      card: card ?? this.card,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<ElementColors> lerp(
      ThemeExtension<ElementColors>? other, double t) {
    if (other is! ElementColors) {
      return this;
    }

    return ElementColors(
      card: Color.lerp(card, other.card, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
