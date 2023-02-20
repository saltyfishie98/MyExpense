import 'dart:math';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:state_extended/state_extended.dart';

class DatetimeRange {
  const DatetimeRange(
    this.start,
    this.end,
  );

  final DateTime start;
  final DateTime end;
}

class MainController extends StateXController {
  static MainController? _this;
  factory MainController() => _this ??= MainController._();
  MainController._() : super();

  _Model _model = _Model(categoryTable: "", expenseTable: "");
  late Database _database;

  int get dailySectionsCount => _model.expenseData.length;
  List<String> get categories => _model.categories;

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

  static String formatTotalStr(List<int> list) {
    return (list.reduce((a, b) => a + b) / 100).toStringAsFixed(2);
  }

  Future<void> setup({
    required Database database,
    required String categoryTable,
    required String expenseTable,
  }) async {
    _database = database;
    _model = _Model(
      categoryTable: categoryTable,
      expenseTable: expenseTable,
    );

    final res = await Future.wait([
      _database.query(_model.expenseTable),
      _database.query(
        _model.categoryTable,
        columns: ["category"],
      ),
    ]);

    final dbExpense = res.first;
    final dbCategories = res.last;

    for (final data in dbExpense) {
      _model.addExpense(
        Expense(
          datetime: DateTime.parse(data["datetime"].toString()),
          amount: data["amount"] as int,
          title: data["title"].toString(),
          category: data["category"].toString(),
        ),
      );
    }

    for (final data in dbCategories) {
      _model.categories.add(data["category"].toString());
    }
  }

  Future<void> addExpense(Expense expense) async {
    /// Checks if current expense's datatime exists in the database;
    /// if it exists add 1 microsecond to the current expense's datetime.
    ///
    /// This was done because the datetime string was used as the primary key.
    /// As such 2 exactly same datetime would cause an database insertion error.
    while (true) {
      final check = await _database.query(
        _model.expenseTable,
        where: "datetime = '${expense.datetime}'",
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
    _database.insert(_model.expenseTable, {
      "datetime": expense.datetime.toString(),
      "amount": expense.amount,
      "title": expense.title,
      "category": expense.category,
    });

    /// Check the inserted expense exist in the database
    final insert = await _database.query(
      _model.expenseTable,
      where: "datetime = '${expense.datetime}'",
    );

    /// Copy the database's expense into the model
    for (final data in insert) {
      _model.addExpense(
        Expense(
          datetime: DateTime.parse(data["datetime"].toString()),
          amount: data["amount"] as int,
          title: data["title"].toString(),
          category: data["category"].toString(),
        ),
      );
    }
  }

  Future<void> editExpense({
    required Expense oldExpense,
    required Expense newExpense,
  }) async {
    await _database.update(
      _model.expenseTable,
      {
        "datetime": newExpense.datetime.toString(),
        "amount": newExpense.amount,
        "title": newExpense.title,
        "category": newExpense.category,
      },
      where: "datetime='${oldExpense.datetime}'",
    );

    _model.editExpense(
      oldExpense: oldExpense,
      newExpense: newExpense,
    );
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

  void deleteExpense(Expense expense) {
    _database.delete(
      _model.expenseTable,
      where: "datetime='${expense.datetime}'",
    );
    _model.deleteExpense(expense);
  }

  List<int> getThisWeekDailyTotal() {
    var dailyData = List<int>.filled(7, 0, growable: false);

    if (_model.expenseData.isEmpty) return dailyData;

    final range = getThisWeekRange();
    final thisMonday = range.start;
    final nextMonday = range.end;

    for (final dailySection in _model.expenseData) {
      final sectionDate = dailySection.first.datetime;
      if (sectionDate.isAfter(thisMonday) && sectionDate.isBefore(nextMonday)) {
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

      if (sectionDate.isAfter(thisMonthStart) &&
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

      if (sectionDate.isAfter(thisYearStart) &&
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

class _Model {
  _Model({
    required this.categoryTable,
    required this.expenseTable,
  });

  final String categoryTable;
  final String expenseTable;

  List<List<Expense>> expenseData = [];
  List<String> categories = [];

  void addExpense(Expense expense) {
    // Create a new daily section if none exists
    if (expenseData.isEmpty) {
      expenseData.add([expense]);
      return;
    }

    for (var i = 0; i < expenseData.length; ++i) {
      final sectionDate = expenseData[i].first.datetime;
      final current = expense.datetime;

      // Add to existing day section else
      // Create a new day section if section does not exist
      if (current.year == sectionDate.year &&
          current.month == sectionDate.month &&
          current.day == sectionDate.day) {
        expenseData[i].add(expense);
        break;
      } else if (i + 1 == expenseData.length) {
        expenseData.add([expense]);
        break;
      }
    }

    // Sort daily sections
    expenseData.sort(
      (a, b) => b.first.datetime.compareTo(a.first.datetime),
    );

    // Sort entries in daily sections
    for (final data in expenseData) {
      data.sort((a, b) => b.datetime.compareTo(a.datetime));
    }
  }

  void editExpense({
    required Expense oldExpense,
    required Expense newExpense,
  }) {
    final index = findDailySectionWith(oldExpense.datetime);

    addExpense(newExpense);
    expenseData[index].remove(oldExpense);
  }

  void deleteExpense(Expense expense) {
    final index = findDailySectionWith(expense.datetime);
    expenseData[index].remove(expense);

    if (expenseData[index].isEmpty) {
      expenseData.removeAt(index);
    }
  }

  int findDailySectionWith(DateTime datetime) {
    return expenseData.indexWhere(
      (dailySection) {
        final sectionDate = dailySection.first.datetime;
        final expenseDate = datetime;

        return sectionDate.year == expenseDate.year &&
            sectionDate.month == expenseDate.month &&
            sectionDate.day == expenseDate.day;
      },
    );
  }
}

class Expense {
  Expense({
    required this.datetime,
    required this.amount,
    required this.title,
    required this.category,
  });

  final DateTime datetime;
  final int amount;
  final String title;
  final String category;

  Expense copyWith({
    DateTime? datetime,
    int? amount,
    String? title,
    String? category,
  }) {
    datetime ??= this.datetime;
    amount ??= this.amount;
    title ??= this.title;
    category ??= this.category;

    return Expense(
      datetime: datetime,
      amount: amount,
      title: title,
      category: category,
    );
  }
}
