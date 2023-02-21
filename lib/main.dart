import "dart:developer";
import "dart:io";

import "package:desktop_window/desktop_window.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:my_expense/data/controller.dart';
import "package:my_expense/pages/home.dart";
import 'package:my_expense/data/tables.dart';
import "package:my_expense/theme.dart";

import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:sqflite/sqflite.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DesktopWindow.setWindowSize(const Size(375, 375 * (18 / 9)));
  }

  final db = await openDatabase(
    // TODO: Rename on release
    "expenses-t1.sqlite",
    version: 1,
    onUpgrade: (db, oldVersion, newVersion) {
      log("database upgraded!");
    },
    onCreate: (db, version) {
      log("database created!");

      db.execute("""
        CREATE TABLE ${CategoryTable.tableName}(
          ${CategoryTable.title} TEXT PRIMARY KEY, 
          ${CategoryTable.icon} INT, 
          ${CategoryTable.color} INT,
          ${CategoryTable.position} INT
        );
      """);
      db.execute("""
        CREATE TABLE ${ExpenseTable.tableName}(
          ${ExpenseTable.datetime} TEXT PRIMARY KEY,
          ${ExpenseTable.amount} INT,
          ${ExpenseTable.title} TEXT,
          ${ExpenseTable.category} TEXT NOT NULL,
          FOREIGN KEY (category) REFERENCES Categories(${CategoryTable.title})
        );
      """);
      db.insert(CategoryTable.tableName, {
        CategoryTable.title: "Food",
        "position": 0,
      });
      db.insert(CategoryTable.tableName, {
        CategoryTable.title: "Shopping",
        "position": 1,
      });
      db.insert(CategoryTable.tableName, {
        CategoryTable.title: "Bicycle",
        "position": 2,
      });
      db.insert(CategoryTable.tableName, {
        CategoryTable.title: "Studies",
        "position": 3,
      });
    },
  );

  await MainController().setup(database: db);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return DynamicColorBuilder(
      builder: (ColorScheme? deviceLight, ColorScheme? deviceDark) {
        // setup themes
        AppTheme.setup(
          light: deviceLight,
          dark: deviceDark,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const HomePage(),
        );
      },
    );
  }
}
