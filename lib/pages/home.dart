import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:state_extended/state_extended.dart';
import 'package:my_expense/controller.dart';
import 'package:my_expense/pages/expense_entry.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/elements/radio_option.dart';

enum GraphMode { week, month, year }

extension ParseToString on GraphMode {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends StateX<HomePage> {
  GraphMode currentGraph = GraphMode.week;
  late MainController ctrlr;
  ExpenseChart? expenseChart;

  _HomePageState() : super(MainController()) {
    ctrlr = controller as MainController;
    expenseChart = ExpenseChart(dailyTotal: ctrlr.getThisWeekDailyTotal());
  }

  Widget headerLogo() {
    return const Row(
      children: [
        Text(
          "MyExpense",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget radioSelector(ThemeData theme) {
    var radioOptions = <Widget>[];
    final elmtThemes = theme.extension<ElementThemes>();

    for (final mode in GraphMode.values) {
      radioOptions.add(
        Expanded(
          child: _radioOption(
            context,
            title: mode.toShortString().capitalize(),
            value: mode,
            groupValue: currentGraph,
            onChanged: (current) => setState(() {
              currentGraph = current!;
            }),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        width: double.infinity,
        height: 42,
        decoration: BoxDecoration(
          color: elmtThemes?.subsurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: radioOptions,
        ),
      ),
    );
  }

  Widget dailyEntryView(ThemeData theme) {
    return ListView.builder(
      itemCount: ctrlr.dailySectionsCount,
      itemBuilder: (context, index) {
        final data = ctrlr.dailyDataAt(index);
        final dateStr = MainController.formatDateString(
          data.first.datetime,
        );

        return StickyHeader(
          //// Date Label //////////////////////////////////////////////////////////
          header: _entryDateHeader(
            context,
            theme: theme,
            dateStr: dateStr,
          ),

          //// Entry List //////////////////////////////////////////////////////////
          content: _dailyEntries(
            context,
            onLongPress: toEditExpense,
            entries: data,
          ),
        );
      },
    );
  }

  void toEditExpense(expense) {
    final page = MaterialPageRoute(
      builder: (context) => ExpenseEntry(
        "Edit\nExpense:",
        onNewExpense: null,
        onEditExpense: () {
          setState(() {
            expenseChart = ExpenseChart(
              dailyTotal: ctrlr.getThisWeekDailyTotal(),
            );
          });
        },
        expense: expense,
      ),
    );

    Navigator.push(context, page);
  }

  void toAddExpense() async {
    final page = MaterialPageRoute(
      builder: (context) => ExpenseEntry(
        "Add\nExpense:",
        onNewExpense: () {
          setState(() {
            expenseChart = ExpenseChart(
              dailyTotal: ctrlr.getThisWeekDailyTotal(),
            );
          });
        },
        onEditExpense: null,
      ),
    );

    Navigator.push(context, page);
  }

  Widget addEntryButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: toAddExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              //// Title ///////////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 10),
              headerLogo(),

              //// Graph ///////////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              expenseChart!,

              //// Selection ///////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 20),
              radioSelector(theme),

              //// Entries /////////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    //// Daily Entries Section View ////////////////////////////////////////////////
                    dailyEntryView(theme),

                    //// Add Entry Button //////////////////////////////////////////////////////////
                    addEntryButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//// Radio Selector ////////////////////////////////////////////////////////////////////////////////

Widget _radioOption<T>(
  BuildContext context, {
  required String title,
  required T value,
  required T groupValue,
  required ValueChanged<T?> onChanged,
}) {
  final theme = Theme.of(context);
  final elmtThemes = theme.extension<ElementThemes>();

  Widget createWidget({required Color? color, bool useShadow = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      width: 100,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: !useShadow
            ? null
            : [
                BoxShadow(
                  blurRadius: 7,
                  spreadRadius: -1,
                  offset: const Offset(0, 1),
                  color: elmtThemes?.shadow ?? Colors.grey,
                ),
              ],
        color: color,
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  return RadioOption<T>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    activeWidget: createWidget(color: elmtThemes?.card ?? Colors.white),
    dormentWidget: createWidget(color: null, useShadow: false),
  );
}

//// Daily Entries Section /////////////////////////////////////////////////////////////////////////

Widget _entryDateHeader(
  BuildContext context, {
  required ThemeData theme,
  required String dateStr,
}) {
  return Container(
    width: double.infinity,
    color: theme.canvasColor,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: 15,
          color: theme.extension<ElementThemes>()?.h3Color,
        ),
      ),
    ),
  );
}

Widget _dailyEntries(
  BuildContext context, {
  required Function(Expense) onLongPress,
  required List<Expense> entries,
}) {
  final elmtThemes = Theme.of(context).extension<ElementThemes>();
  List<Widget> entryList = [];

  for (final expense in entries) {
    entryList.add(
      Container(
        width: double.infinity,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
        ),
        child: InkWell(
          onLongPress: () => onLongPress(expense),
          onTap: () {},
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //// Icon ////////////////////////////////////////////////////////////////////////

                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: elmtThemes?.accent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: elmtThemes?.shadow ?? Colors.black,
                              blurRadius: 5.0,
                              offset: const Offset(1, 2))
                        ],
                      ),
                    ),

                    //// Title ///////////////////////////////////////////////////////////////////////

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.0, horizontal: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(fontSize: 17),
                          ),
                          Text(
                            expense.category,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                //// Amount //////////////////////////////////////////////////////////////////////////

                Text(
                  "\$${(expense.amount / 100).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  return Column(
    children: entryList,
  );
}

//// Expense Chart /////////////////////////////////////////////////////////////////////////////////

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key, required this.dailyTotal});

  final List<int> dailyTotal;

  @override
  Widget build(BuildContext context) {
    final elmtThemes = Theme.of(context).extension<ElementThemes>();

    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        color: elmtThemes?.card,
        borderRadius: BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
        boxShadow: [
          BoxShadow(
            blurRadius: 7,
            color: elmtThemes?.shadow ?? Colors.black,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 30,
                  child: Align(
                    alignment: FractionalOffset.bottomRight,
                    child: Text(
                      "Total: ",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                Text(
                  "\$${(dailyTotal.reduce((a, b) => a + b) / 100).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
            const SizedBox(width: double.infinity, height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    barGroups: _thisWeekChart(
                      context,
                      dailyTotal: dailyTotal,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 24,
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              "Mon",
                              "Tue",
                              "Wed",
                              "Thu",
                              "Fri",
                              "Sat",
                              "Sun",
                            ];

                            return Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<BarChartGroupData> _thisWeekChart(
  BuildContext context, {
  required List<int> dailyTotal,
}) {
  var out = <BarChartGroupData>[];

  for (var i = 0; i < 7; ++i) {
    out.add(BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: dailyTotal[i].toDouble() / 100,
          color: Theme.of(context).extension<ElementThemes>()?.onCard,
        )
      ],
    ));
  }

  return out;
}
