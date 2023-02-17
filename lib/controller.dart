import 'package:sqflite/sqflite.dart';
import 'package:state_extended/state_extended.dart';

class Controller extends StateXController {
  static Controller? _this;

  late _Model _model;
  late Database _database;
  Database get database => _database;

  void setup({
    required Database database,
    required String categoryTable,
    required String expenseTable,
  }) async {
    _database = database;
    _model = _Model(
      categoryTable: categoryTable,
      expenseTable: expenseTable,
    );

    final dbCategories = await _database.query(
      _model.categoryTable,
      columns: ["category"],
    );

    final dbExpense = await _database.query(_model.expenseTable);

    for (final data in dbCategories) {
      _model.categories.add(data["category"].toString());
    }

    for (final data in dbExpense) {
      _model.expenseData.add(
        Expense(
          datetime: DateTime.parse(data["datetime"].toString()),
          amount: data["amount"] as int,
          title: data["title"].toString(),
          category: data["category"].toString(),
        ),
      );
    }
  }

  void addExpense(Expense expense) async {
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
      _model.expenseData.add(
        Expense(
          datetime: DateTime.parse(data["datetime"].toString()),
          amount: data["amount"] as int,
          title: data["title"].toString(),
          category: data["category"].toString(),
        ),
      );
    }
  }

  factory Controller() => _this ??= Controller._();
  Controller._() : super();
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

class _Model {
  _Model({
    required this.categoryTable,
    required this.expenseTable,
  });

  final String categoryTable;
  final String expenseTable;

  List<Expense> expenseData = [];
  List<String> categories = [];
}
