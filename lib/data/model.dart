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

  Category copyWith({
    String? title,
    Color? color,
    Icon? icon,
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
}

class DatetimeRange {
  const DatetimeRange(
    this.start,
    this.end,
  );

  final DateTime start;
  final DateTime end;
}
