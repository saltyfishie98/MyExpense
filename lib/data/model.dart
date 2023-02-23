part of controller;

class _Model {
  List<List<Expense>> expenseData = [];
  List<Category> categories = [];

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
    // ORDER MATTERS!!!
    addExpense(newExpense);
    expenseData[findDailySectionWith(oldExpense.datetime)].remove(oldExpense);
    expenseData.removeWhere((element) => element.isEmpty);
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
  const Expense({
    required this.datetime,
    required this.amount,
    required this.title,
    required this.category,
  });

  final DateTime datetime;
  final int amount;
  final String title;
  final Category category;

  static Future<List<Map<String, Object?>>> rawQuery(Database database) =>
      database.rawQuery("""
        SELECT ${ExpenseTable.datetime}, ${ExpenseTable.amount}, l.${ExpenseTable.title}, ${ExpenseTable.category}, ${CategoryTable.icon}, ${CategoryTable.iconFamily}, ${CategoryTable.color}, ${CategoryTable.position}
        FROM ${ExpenseTable.tableName} l
        INNER JOIN ${CategoryTable.tableName} r ON 
        	r.${CategoryTable.title}=l.${ExpenseTable.category} 
      """);

  static Expense fromDatabase(Map<String, Object?> data) {
    final datetime = DateTime.parse(data[ExpenseTable.datetime].toString());
    final amount = int.parse(data[ExpenseTable.amount].toString());
    final title = data[ExpenseTable.title].toString();
    final category = data[ExpenseTable.category].toString();

    final iconFamily = data[CategoryTable.iconFamily];
    final iconFamilyData =
        iconFamily == null ? "MaterialIcons" : iconFamily.toString();

    final iconCode = data[CategoryTable.icon];
    final iconData =
        int.parse(iconCode == null ? "0xe16a" : iconCode.toString());
    final icon = Icon(IconData(iconData, fontFamily: iconFamilyData));

    final colorCode = data[CategoryTable.color];
    final colorData =
        colorCode == null ? Colors.red.value : int.parse(colorCode.toString());
    final color = Color(colorData);

    final position = int.parse(data[CategoryTable.position].toString());

    return Expense(
      datetime: datetime,
      amount: amount,
      title: title,
      category: Category(
        title: category,
        color: color,
        icon: icon,
        position: position,
      ),
    );
  }

  Expense copyWith({
    DateTime? datetime,
    int? amount,
    String? title,
    Category? category,
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

class Category {
  const Category({
    required this.title,
    required this.color,
    required this.icon,
    required this.position,
  });

  final String title;
  final Color color;
  final Icon icon;
  final int position;

  static Future<List<Map<String, Object?>>> rawQuery(Database database) =>
      database.query(
        CategoryTable.tableName,
        orderBy: CategoryTable.position,
      );

  static Category fromDatabase(Map<String, Object?> data) {
    final colorData = data[CategoryTable.color]?.toString();
    final iconData = data[CategoryTable.icon]?.toString();
    final posData = data[CategoryTable.position]?.toString();
    final iconFamilyData = data[CategoryTable.iconFamily]?.toString();

    final position = posData == null ? -1 : int.parse(posData.toString());
    final colorCode =
        colorData == null ? Colors.red.value : int.parse(colorData);
    final iconCode = iconData == null ? 0xe16a : int.parse(iconData.toString());
    final iconFamily =
        iconFamilyData == null ? "MaterialIcons" : iconFamilyData.toString();

    return Category(
      title: data[CategoryTable.title].toString(),
      color: Color(colorCode),
      icon: Icon(IconData(iconCode, fontFamily: iconFamily)),
      position: position,
    );
  }

  Category copyWith({
    String? title,
    Color? color,
    Icon? icon,
    String? iconFamily,
    int? position,
  }) {
    title ??= this.title;
    color ??= this.color;
    icon ??= this.icon;
    position ??= this.position;

    return Category(
      title: title,
      color: color,
      icon: icon,
      position: position,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && title == other.title;
  }

  @override
  int get hashCode => Object.hash(title, 42);
}

class DatetimeRange {
  const DatetimeRange(
    this.start,
    this.end,
  );

  final DateTime start;
  final DateTime end;
}
