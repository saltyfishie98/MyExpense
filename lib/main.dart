import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:my_expense/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? deviceLight, ColorScheme? deviceDark) {
        ColorScheme light;
        ColorScheme dark;

        if (deviceLight != null && deviceDark != null) {
          light = deviceLight.harmonized();
          dark = deviceDark.harmonized();
        } else {
          light = ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 85, 199, 187),
          );
          dark = ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 85, 199, 187),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: dark,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
