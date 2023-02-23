import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _cardRadius = 20.0;

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
        brightness: Brightness.light,
        iconTheme: const IconThemeData(color: Colors.black),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStateProperty.all(
              lightScheme.onBackground,
            ),
          ),
        ),
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: lightScheme.inversePrimary,
            onCard: lightScheme.primary,
            cardRadius: _cardRadius,
            shadow: Colors.grey.shade400,
            accent: lightScheme.surfaceVariant,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade500,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        useMaterial3: _useMaterial3,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        iconTheme: const IconThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStateProperty.all(
              darkScheme.onBackground,
            ),
          ),
        ),
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: darkScheme.inversePrimary,
            onCard: darkScheme.primary,
            cardRadius: _cardRadius,
            shadow: Colors.black,
            accent: darkScheme.surfaceVariant,
            subsurface: const Color.fromRGBO(0, 0, 0, .22),
            h3Color: Colors.grey.shade600,
          ),
        ],
      );
      //
    } else {
      const swatchColor = Color(0xff23703d);

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
      )
          .copyWith(
            brightness: Brightness.light,
            primary: const Color.fromARGB(255, 55, 177, 95),
            onPrimary: const Color.fromARGB(255, 37, 121, 66),
            primaryContainer: const Color(0xff23703d),
            onPrimaryContainer: const Color(0xff23703d),
            secondary: const Color.fromARGB(255, 51, 161, 87),
            onSecondary: const Color.fromARGB(255, 214, 214, 214),
            surfaceVariant: const Color.fromARGB(255, 83, 204, 123),
            background: Colors.grey.shade300,
          )
          .harmonized();

      darkScheme = ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
        brightness: Brightness.dark,
      )
          .copyWith(
            brightness: Brightness.dark,
            primary: const Color(0xff23703d),
            onPrimary: const Color.fromARGB(255, 22, 71, 38),
            primaryContainer: const Color(0xff23703d),
            onPrimaryContainer: const Color(0xff23703d),
            secondary: const Color(0xff23703d),
            onSecondary: const Color.fromARGB(255, 199, 199, 199),
            surfaceVariant: const Color.fromARGB(255, 20, 73, 38),
          )
          .harmonized();

      AppTheme.light = ThemeData(
        colorScheme: lightScheme,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: lightScheme.primary,
            onCard: lightScheme.onPrimary,
            cardRadius: _cardRadius,
            shadow: Colors.grey.shade400,
            accent: lightScheme.surfaceVariant,
            subsurface: Colors.grey.shade200,
            h3Color: Colors.grey.shade500,
          ),
        ],
      );

      AppTheme.dark = ThemeData(
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          ElementThemes(
            card: darkScheme.primary,
            onCard: darkScheme.onPrimary,
            cardRadius: _cardRadius,
            shadow: Colors.black,
            accent: darkScheme.surfaceVariant,
            subsurface: const Color.fromRGBO(0, 0, 0, .22),
            h3Color: Colors.grey.shade600,
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
    required this.onCard,
    required this.cardRadius,
    required this.shadow,
    required this.accent,
    required this.subsurface,
    required this.h3Color,
  });

  final Color card;
  final Color onCard;
  final double cardRadius;
  final Color shadow;
  final Color accent;
  final Color subsurface;
  final Color h3Color;

  @override
  ThemeExtension<ElementThemes> copyWith({
    Color? card,
    Color? onCard,
    double? cardRadius,
    Color? shadow,
    Color? accent,
    Color? subsurface,
    Color? h3Color,
  }) {
    return ElementThemes(
      card: card ?? this.card,
      onCard: onCard ?? this.onCard,
      cardRadius: cardRadius ?? this.cardRadius,
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
      onCard: Color.lerp(onCard, other.onCard, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      subsurface: Color.lerp(subsurface, other.subsurface, t)!,
      h3Color: Color.lerp(h3Color, other.h3Color, t)!,
    );
  }
}
