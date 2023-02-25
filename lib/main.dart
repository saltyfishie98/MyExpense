import "dart:developer";
import "dart:io";

import "package:desktop_window/desktop_window.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:fluttericon/font_awesome_icons.dart";
import "package:fluttericon/iconic_icons.dart";
import "package:fluttericon/maki_icons.dart";
import "package:fluttericon/typicons_icons.dart";
import 'package:my_expense/data/controller.dart';
import "package:my_expense/pages/home.dart";
import "package:my_expense/theme.dart";

import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:sqflite/sqflite.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DesktopWindow.setWindowSize(const Size(360, 800));
    // await DesktopWindow.setWindowSize(const Size(375, 375 * (18 / 9)));
  }

  if (Platform.isAndroid) {
    MainController.initHomeWidget();
  }

  final db = await openDatabase(
    // TODO: Rename on release
    "expenses-t2.sqlite",
    version: 1,
    onUpgrade: (db, oldVersion, newVersion) {
      log("database upgraded!");
    },
    onCreate: (db, version) {
      log("database created!");

      db.execute("""
        CREATE TABLE ${Category.tableNameCol}(
          ${Category.titleCol} TEXT PRIMARY KEY, 
          ${Category.iconCol} INT NOT NULL, 
          ${Category.iconFamilyCol} TEXT NOT NULL, 
          ${Category.iconPackageCol} TEXT, 
          ${Category.colorCol} INT NOT NULL,
          ${Category.positionCol} INT NOT NULL
        );
      """);
      db.execute("""
        CREATE TABLE ${Expense.tableNameCol}(
          ${Expense.datetimeCol} TEXT PRIMARY KEY,
          ${Expense.amountCol} INT NOT NULL,
          ${Expense.titleCol} TEXT NOT NULL,
          ${Expense.categoryCol} TEXT NOT NULL,
          FOREIGN KEY (category) REFERENCES Categories(${Category.titleCol})
        );
      """);
      db.insert(
        Category.tableNameCol,
        const Category(
          title: "Food",
          color: Colors.red,
          icon: Icon(FontAwesome.food),
          position: 0,
        ).toDatabaseObject(),
      );
      db.insert(
        Category.tableNameCol,
        const Category(
          title: "Shopping",
          color: Colors.red,
          icon: Icon(Typicons.basket),
          position: 0,
        ).toDatabaseObject(),
      );
      db.insert(
        Category.tableNameCol,
        const Category(
          title: "Sports",
          color: Colors.red,
          icon: Icon(Maki.bicycle),
          position: 0,
        ).toDatabaseObject(),
      );
      db.insert(
        Category.tableNameCol,
        const Category(
          title: "Studies",
          color: Colors.red,
          icon: Icon(Iconic.book_open),
          position: 0,
        ).toDatabaseObject(),
      );
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
