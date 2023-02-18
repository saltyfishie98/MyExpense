import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:state_extended/state_extended.dart';

class Controller extends StateXController {
  void logExpenseData() {
    log("Expense Data:");
    for (final section in _model.expenseData) {
      log("   ${section.first.datetime.toString()}");
      for (final entry in section) {
        log("       datetime: ${entry.datetime}, title: ${entry.title}");
      }
      log("\n");
    }
  }

  static Controller? _this;

  _Model _model = _Model(categoryTable: "", expenseTable: "");
  late Database _database;

  int get dailySectionsCount => _model.expenseData.length;

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
      _expenseDataAdd(
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

    logExpenseData();
  }

  Future<void> addExpense(Expense expense) async {
    _database.insert(_model.expenseTable, {
      "datetime": "${expense.datetime}",
      "amount": expense.amount,
      "title": expense.title,
      "category": expense.category,
    });

    final query = await _database.query(
      _model.expenseTable,
      where: "datetime = '${expense.datetime}'",
    );

    for (final data in query) {
      _expenseDataAdd(
        Expense(
          datetime: DateTime.parse(data["datetime"].toString()),
          amount: data["amount"] as int,
          title: data["title"].toString(),
          category: data["category"].toString(),
        ),
      );
    }
  }

  List<Expense> dailyDataAt(int index) {
    return _model.expenseData[index];
  }

  void _expenseDataAdd(Expense expense) {
    if (_model.expenseData.isEmpty) {
      _model.expenseData.add([expense]);
      return;
    }

    for (var i = 0; i < _model.expenseData.length; ++i) {
      final sectionDate = _model.expenseData[i].first.datetime;
      final current = expense.datetime;

      if (current.year == sectionDate.year &&
          current.month == sectionDate.month &&
          current.day == sectionDate.day) {
        _model.expenseData[i].add(expense);
        break;
      } else if (i + 1 == _model.expenseData.length) {
        _model.expenseData.add([expense]);
        break;
      }
    }

    _model.expenseData.sort(
      (a, b) => b.first.datetime.compareTo(a.first.datetime),
    );
  }

  factory Controller() => _this ??= Controller._();
  Controller._() : super();
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
}
