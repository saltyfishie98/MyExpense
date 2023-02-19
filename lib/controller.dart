import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:state_extended/state_extended.dart';

class MainController extends StateXController {
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

  static MainController? _this;

  _Model _model = _Model(categoryTable: "", expenseTable: "");
  late Database _database;

  int get dailySectionsCount => _model.expenseData.length;
  List<String> get categories => _model.categories;

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
      _addExpenseToModel(
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
      "datetime": "${expense.datetime}",
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
      _addExpenseToModel(
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

  void _addExpenseToModel(Expense expense) {
    // Create a new daily section if none exists
    if (_model.expenseData.isEmpty) {
      _model.expenseData.add([expense]);
      return;
    }

    for (var i = 0; i < _model.expenseData.length; ++i) {
      final sectionDate = _model.expenseData[i].first.datetime;
      final current = expense.datetime;

      // Add to existing day section else
      // Create a new day section if section does not exist
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

    // Sort daily sections
    _model.expenseData.sort(
      (a, b) => b.first.datetime.compareTo(a.first.datetime),
    );

    // Sort entries in daily sections
    for (final data in _model.expenseData) {
      data.sort((a, b) => b.datetime.compareTo(a.datetime));
    }
  }

  factory MainController() => _this ??= MainController._();
  MainController._() : super();
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
