import "dart:io";

import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:my_expense/controller.dart";
import "package:my_expense/pages/home.dart";
import "package:my_expense/theme.dart";

import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:sqflite/sqflite.dart";

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  const expenseTable = "Expenses";
  const categoryTable = "Categories";

  openDatabase(
    "expenses.sqlite",
    version: 1,
    onUpgrade: (db, oldVersion, newVersion) {},
    onCreate: (db, version) {
      return db.execute("""
        CREATE TABLE $categoryTable(category TEXT PRIMARY KEY);
        CREATE TABLE $expenseTable(
          datetime TEXT PRIMARY KEY,
          amount INT,
          title TEXT,
          category TEXT NOT NULL,
          FOREIGN KEY (category) REFERENCES Categories(category)
        );
      """);
    },
  ).then((db) {
    Controller().setup(
      database: db,
      categoryTable: categoryTable,
      expenseTable: expenseTable,
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
