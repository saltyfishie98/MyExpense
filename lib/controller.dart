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

    final res = await _database.query(
      _model.categoryTable,
      columns: ["category"],
    );

    for (final data in res) {
      _model.categories.add(data["category"].toString());
    }
  }

  void addExpense(Expense expense) {}

  factory Controller() => _this ??= Controller._();
  Controller._() : super();
}

class Expense {
  DateTime datetime = DateTime(0);
  int amount = 0;
  String title = "";
  String category = "";
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
