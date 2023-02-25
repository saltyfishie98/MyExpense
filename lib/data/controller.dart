library controller;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:state_extended/state_extended.dart';
import 'package:home_widget/home_widget.dart';

part 'model.dart';

class MainController extends StateXController {
  static MainController? _this;
  factory MainController() => _this ??= MainController._();
  MainController._() : super();

  _Model _model = _Model();
  late Database _database;

  int get dailySectionsCount => _model.expenseData.length;
  List<Category> get categories => _model.categories;

  //// Setup ///////////////////////////////////////////////////////////////////////////////////////

  Future<void> setup({required Database database}) async {
    _database = database;
    _model = _Model();

    final res = await Future.wait([
      Expense.rawQuery(_database),
      Category.rawQuery(_database),
    ]);

    final dbExpense = res.first;
    final dbCategories = res.last;

    for (final data in dbExpense) {
      _model.addExpense(Expense.fromDatabase(data));
    }

    for (final data in dbCategories) {
      _model.categories.add(Category.fromDatabase(data));
    }
  }

  //// Expense /////////////////////////////////////////////////////////////////////////////////////

  Future<void> addExpense(Expense expense) async {
    /// Checks if current expense's datatime exists in the database;
    /// if it exists add 1 microsecond to the current expense's datetime.
    ///
    /// This was done because the datetime string was used as the primary key.
    /// As such 2 exactly same datetime would cause an database insertion error.
    while (true) {
      final check = await _database.query(
        Expense.tableName,
        where: "${Expense.datetimeCol} = '${expense.datetime}'",
      );

      if (check.isEmpty) {
        break;
      }

      final datetime = expense.datetime;
      expense = expense.copyWith(
        datetime: DateTime(
          datetime.year,
          datetime.month,
          datetime.day,
          datetime.hour,
          datetime.minute,
          datetime.second,
          datetime.millisecond,
          datetime.microsecond + 1,
        ),
      );
    }

    /// Actualy insert into the database after the above check
    _database.insert(
      Expense.tableName,
      Expense(
        datetime: expense.datetime,
        amount: expense.amount,
        title: expense.title,
        category: expense.category,
      ).toDatabaseObject(),
    );

    /// Check the inserted expense exist in the database
    final res = await _database.query(
      Expense.tableName,
      where: "${Expense.datetimeCol} = '${expense.datetime}'",
    );

    /// Copy expense into the model
    if (res.length == 1) {
      _model.addExpense(expense);
    }
  }

  Future<void> editExpense({
    required Expense oldExpense,
    required Expense newExpense,
  }) async {
    await _database.update(
      Expense.tableName,
      {
        Expense.datetimeCol: newExpense.datetime.toString(),
        Expense.amountCol: newExpense.amount,
        Expense.titleCol: newExpense.title,
        Expense.categoryCol: newExpense.category.title,
      },
      where: "${Expense.datetimeCol}='${oldExpense.datetime}'",
    );

    _model.editExpense(
      oldExpense: oldExpense,
      newExpense: newExpense,
    );
  }

  void deleteExpense(Expense expense) {
    _database.delete(
      Expense.tableName,
      where: "${Expense.datetimeCol}='${expense.datetime}'",
    );
    _model.deleteExpense(expense);
  }

  //// Categories //////////////////////////////////////////////////////////////////////////////////

  Future<List<Category>> getCategories() async {
    final categories = await _database.query(
      Category.tableName,
      orderBy: Category.positionCol,
    );

    final out = categories.map((data) => Category.fromDatabase(data)).toList();

    return Future(() => out);
  }

  void commitCategories(List<Category> categories) {
    _model.categories = categories;

    for (final category in _model.categories) {
      final iconData = category.icon.icon!;

      // this was done to not sent "null" as string
      final String? fontPackage =
          iconData.fontPackage == null ? null : "'${iconData.fontPackage}'";

      _database.execute("""
      INSERT OR REPLACE INTO ${Category.tableName} (${Category.titleCol}, ${Category.iconCol}, ${Category.iconFamilyCol}, ${Category.iconPackageCol}, ${Category.colorCol}, ${Category.positionCol})
      VALUES('${category.title}', ${iconData.codePoint}, '${iconData.fontFamily}', $fontPackage, ${category.color.value}, ${category.position} );
      """);
    }
  }

  Future<bool> addCategory(Category category) async {
    if (_model.categories
            .indexWhere((element) => element.title == category.title) !=
        -1) {
      return false;
    }

    _model.categories.insert(_model.categories.length, category);

    return true;
  }

  Future<bool> deleteCategory(Category category) async {
    // don't delete if saved expense has the specified category
    for (final section in _model.expenseData) {
      if (section.indexWhere((element) => element.category == category) != -1) {
        return Future(() => false);
      }
    }

    await _database.delete(
      Category.tableName,
      where: "${Category.titleCol}='${category.title}'",
    );

    final res = await _database.query(Category.tableName,
        columns: [Category.colorCol],
        where: "${Category.titleCol}='${category.title}'");

    if (res.isEmpty) {
      _model.categories
          .removeWhere((element) => element.title == category.title);
    }

    return Future(() => true);
  }

  //// Home Widget /////////////////////////////////////////////////////////////////////////////////

  static void initHomeWidget() {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    // required for ios only
    HomeWidget.setAppGroupId('MY_EXPENSE_IOS');
  }

  Future<void> updateHomeWidget() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    HomeWidget.updateWidget(
      name: 'MyExpenseWidgetProvider',
      iOSName: 'MyExpenseWidget',
    );
  }

  Future<void> sendHomeWidget(String totalExpense) async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    await HomeWidget.saveWidgetData(
      "amount",
      "\$$totalExpense",
    );
    updateHomeWidget();
  }

  void onHomeWidgetLaunched(Function(Uri?) callback) {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    HomeWidget.initiallyLaunchedFromHomeWidget().then(callback);
  }

  //// Misc ////////////////////////////////////////////////////////////////////////////////////////

  static int formatAmountToInsert(double amount) {
    return (amount * 100).toInt();
  }

  static String formatDateString(DateTime datetime) {
    final today = DateTime.now();

    final bool isToday = datetime.year == today.year &&
        datetime.month == today.month &&
        datetime.day == today.day;

    late String dateStr;
    if (datetime.year == today.year) {
      dateStr = isToday ? "Today" : DateFormat('MMM dd').format(datetime);
    } else {
      dateStr = DateFormat('MMM dd, yyyy').format(datetime);
    }

    return dateStr;
  }

  static String formatTotalAmountForView(List<int> list) {
    return (list.reduce((a, b) => a + b) / 100).toStringAsFixed(2);
  }

  static DatetimeRange getThisWeekRange() {
    final today = DateTime.now();
    final startOffet = today.weekday - 1;
    final endOffset = 8 - today.weekday;

    final thisMonday = DateTime(
      today.year,
      today.month,
      today.day - startOffet,
    );

    final nextMonday = DateTime(
      today.year,
      today.month,
      today.day + endOffset,
    );

    return DatetimeRange(thisMonday, nextMonday);
  }

  static DatetimeRange getThisMonthRange() {
    final today = DateTime.now();
    final thisMonthStart = DateTime(today.year, today.month);
    final nextMonthStart = DateTime(today.year, today.month + 1);

    return DatetimeRange(thisMonthStart, nextMonthStart);
  }

  static DatetimeRange getThisYearRange() {
    final today = DateTime.now();
    final thisYearStart = DateTime(today.year);
    final nextYearStart = DateTime(today.year + 1);

    return DatetimeRange(thisYearStart, nextYearStart);
  }

  List<int> getThisWeekDailyTotal() {
    var dailyData = List<int>.filled(7, 0, growable: false);

    if (_model.expenseData.isEmpty) return dailyData;

    final range = getThisWeekRange();
    final thisMonday = range.start;
    final nextMonday = range.end;

    for (final dailySection in _model.expenseData) {
      final sectionDate = dailySection.first.datetime;
      if ((sectionDate.isAfter(thisMonday) || sectionDate == thisMonday) &&
          sectionDate.isBefore(nextMonday)) {
        final index = sectionDate.weekday - 1;
        for (final expense in dailySection) {
          dailyData[index] += expense.amount;
        }
      }
    }

    return dailyData;
  }

  List<int> getThisMonthWeeklyTotal() {
    final range = getThisMonthRange();
    final thisMonthStart = range.start;
    final nextMonthStart = range.end;

    final numDays = nextMonthStart.copyWith(day: 0).day;

    var weeklyData = List<int>.filled(numDays, 0);

    for (final data in _model.expenseData) {
      final sectionDate = data.first.datetime;

      if ((sectionDate.isAfter(thisMonthStart) ||
              sectionDate == thisMonthStart) &&
          sectionDate.isBefore(nextMonthStart)) {
        for (final expense in data) {
          weeklyData[expense.datetime.day - 1] += expense.amount;
        }
      }
    }

    return weeklyData;
  }

  List<int> getThisYearMonthlyTotal() {
    var monthlyData = List<int>.filled(12, 0, growable: false);

    final range = getThisYearRange();
    final thisYearStart = range.start;
    final nextYearStart = range.end;

    for (final data in _model.expenseData) {
      final sectionDate = data.first.datetime;

      if ((sectionDate.isAfter(thisYearStart) ||
              sectionDate == thisYearStart) &&
          sectionDate.isBefore(nextYearStart)) {
        for (final expense in data) {
          monthlyData[expense.datetime.month - 1] += expense.amount;
        }
      }
    }

    return monthlyData;
  }

  List<Expense> dailyDataAt(int index) {
    return _model.expenseData[index];
  }
}
