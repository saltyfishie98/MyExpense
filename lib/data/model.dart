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

  static String datetimeCol = "datetime";
  static String amountCol = "amount";
  static String titleCol = "title";
  static String categoryCol = "category";
  static String tableName = "Expenses";

  static Future<List<Map<String, Object?>>> rawQuery(Database database) =>
      // Need update if database skema changes!
      database.rawQuery("""
        SELECT $datetimeCol, $amountCol, l.$titleCol, $categoryCol, ${Category.iconCol}, ${Category.iconFamilyCol}, ${Category.colorCol}, ${Category.positionCol}, ${Category.iconPackageCol}
        FROM $tableName l
        INNER JOIN ${Category.tableName} r ON 
        	r.${Category.titleCol}=l.$categoryCol 
      """);

  static Expense fromDatabase(Map<String, Object?> data) {
    // Need update if database skema changes!

    final datetime = DateTime.parse(data[datetimeCol].toString());
    final amount = int.parse(data[amountCol].toString());
    final title = data[titleCol].toString();
    final category = data[categoryCol].toString();

    final iconFamily = data[Category.iconFamilyCol];
    final iconFamilyData =
        iconFamily == null ? "MaterialIcons" : iconFamily.toString();

    final iconPackage = data[Category.iconPackageCol].toString();
    final iconCode = data[Category.iconCol];
    final iconData =
        int.parse(iconCode == null ? "0xe16a" : iconCode.toString());
    final icon = Icon(IconData(
      iconData,
      fontFamily: iconFamilyData,
      fontPackage: iconPackage,
    ));

    final colorCode = data[Category.colorCol];
    final colorData =
        colorCode == null ? Colors.red.value : int.parse(colorCode.toString());
    final color = Color(colorData);

    final position = int.parse(data[Category.positionCol].toString());

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

  Map<String, Object?> toDatabaseObject() {
    // Need update if database skema changes!
    return {
      datetimeCol: datetime.toString(),
      amountCol: amount,
      titleCol: title,
      categoryCol: category.title,
    };
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

  static String titleCol = "title";
  static String iconCol = "icon";
  static String iconFamilyCol = "iconFamily";
  static String iconPackageCol = "iconPackage";
  static String colorCol = "color";
  static String positionCol = "position";
  static String tableName = "Categories";

  static Future<List<Map<String, Object?>>> rawQuery(Database database) =>
      // Need update if database skema changes!
      database.query(
        Category.tableName,
        orderBy: Category.positionCol,
      );

  static Category fromDatabase(Map<String, Object?> data) {
    // Need update if database skema changes!
    final posData = data[Category.positionCol]?.toString();
    final position = posData == null ? -1 : int.parse(posData.toString());

    final colorData = data[Category.colorCol]?.toString();
    final colorCode =
        colorData == null ? Colors.red.value : int.parse(colorData);

    final iconData = data[Category.iconCol]?.toString();
    final iconCode = iconData == null ? 0xe16a : int.parse(iconData);

    final iconFamilyData = data[Category.iconFamilyCol]?.toString();
    final iconFamily =
        iconFamilyData == null ? "MaterialIcons" : iconFamilyData.toString();

    final iconPackage = data[Category.iconPackageCol]?.toString();

    return Category(
      title: data[Category.titleCol].toString(),
      color: Color(colorCode),
      icon: Icon(
          IconData(iconCode, fontFamily: iconFamily, fontPackage: iconPackage)),
      position: position,
    );
  }

  Map<String, Object?> toDatabaseObject() {
    // Need update if database skema changes!
    return {
      Category.titleCol: title,
      Category.iconCol: icon.icon?.codePoint ?? Icons.abc.codePoint,
      Category.iconFamilyCol: icon.icon?.fontFamily ?? "MaterialIcons",
      Category.iconPackageCol: icon.icon?.fontPackage,
      Category.colorCol: color.value,
      Category.positionCol: position,
    };
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
