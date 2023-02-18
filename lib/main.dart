import "dart:developer";
import "dart:io";

import "package:desktop_window/desktop_window.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:my_expense/controller.dart";
import "package:my_expense/pages/home.dart";
import "package:my_expense/theme.dart";

import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:sqflite/sqflite.dart";

void main() async {
  const expenseTable = "Expenses";
  const categoryTable = "Categories";

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DesktopWindow.setWindowSize(const Size(375, 375 * (18 / 9)));
  }

  final db = await openDatabase(
    // TODO: Rename on release
    "expenses123.sqlite",
    version: 3,
    onUpgrade: (db, oldVersion, newVersion) {
      log("database upgraded!");
    },
    onCreate: (db, version) {
      log("database created!");

      db.execute("CREATE TABLE $categoryTable(category TEXT PRIMARY KEY);");
      db.execute("""
        CREATE TABLE $expenseTable(
          datetime TEXT PRIMARY KEY,
          amount INT,
          title TEXT,
          category TEXT NOT NULL,
          FOREIGN KEY (category) REFERENCES Categories(category)
        );
      """);
      db.insert(categoryTable, {"category": "Food"});
      db.insert(categoryTable, {"category": "Shopping"});
      db.insert(categoryTable, {"category": "Bicycle"});
      db.insert(categoryTable, {"category": "Studies"});
    },
  );

  await MainController().setup(
    database: db,
    categoryTable: categoryTable,
    expenseTable: expenseTable,
  );

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
