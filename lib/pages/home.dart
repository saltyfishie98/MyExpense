import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:state_extended/state_extended.dart';
import 'package:my_expense/controller.dart';
import 'package:my_expense/pages/expense_entry.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/elements/widget_radio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

enum Graph { daily, monthly, yearly }

class _HomePageState extends StateX<HomePage> {
  Graph currentGraph = Graph.daily;
  late MainController ctrlr;

  _HomePageState() : super(MainController()) {
    ctrlr = controller as MainController;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elmtThemes = theme.extension<ElementThemes>();
    final today = DateTime.now();

    final dailyTotal = ctrlr.getThisWeekDailyTotal();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              //// Title ///////////////////////////////////////////////////////////////////////////

              const SizedBox(width: double.infinity, height: 10),
              const Row(
                children: [
                  Text(
                    "MyExpense",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              //// Graph ///////////////////////////////////////////////////////////////////////////

              const SizedBox(width: double.infinity, height: 15),
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: elmtThemes?.card,
                  borderRadius:
                      BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
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
                                controller: ctrlr,
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
                                        alignment:
                                            FractionalOffset.bottomCenter,
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
              ),

              //// Selection ///////////////////////////////////////////////////////////////////////

              const SizedBox(width: double.infinity, height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    color: elmtThemes?.subsurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _radioElement(
                          context,
                          title: "Week",
                          value: Graph.daily,
                          groupValue: currentGraph,
                          onChanged: (current) => setState(() {
                            currentGraph = current!;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _radioElement(
                          context,
                          title: "Month",
                          value: Graph.monthly,
                          groupValue: currentGraph,
                          onChanged: (current) => setState(() {
                            currentGraph = current!;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _radioElement(
                          context,
                          title: "Year",
                          value: Graph.yearly,
                          groupValue: currentGraph,
                          onChanged: (current) => setState(() {
                            currentGraph = current!;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //// Entries /////////////////////////////////////////////////////////////////////////

              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    //// Daily Entries Section View ////////////////////////////////////////////////

                    ListView.builder(
                      itemCount: ctrlr.dailySectionsCount,
                      itemBuilder: (context, index) {
                        final data = ctrlr.dailyDataAt(index);
                        final dataDT = data.first.datetime;
                        final bool isToday = dataDT.year == today.year &&
                            dataDT.month == today.month &&
                            dataDT.day == today.day;

                        late String dateStr;
                        if (dataDT.year == today.year) {
                          dateStr = isToday
                              ? "Today"
                              : DateFormat('MMM dd').format(dataDT);
                        } else {
                          dateStr = DateFormat('MMM dd, yyyy').format(dataDT);
                        }

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
                            onLongPress: (expense) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpenseEntry(
                                    "Edit\nExpense:",
                                    onNewExpense: null,
                                    onEditExpense: () => setState(() {}),
                                    expense: expense,
                                  ),
                                ),
                              );
                            },
                            entries: data,
                          ),
                        );
                      },
                    ),

                    //// Add Entry Button //////////////////////////////////////////////////////////

                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () async {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseEntry(
                                  "Add\nExpense:",
                                  onNewExpense: () => setState(() {}),
                                  onEditExpense: null,
                                ),
                              ),
                            );
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
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

List<BarChartGroupData> _thisWeekChart(
  BuildContext context, {
  required List<int> dailyTotal,
  required MainController controller,
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

Widget _radioElement<T>(
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

  return WidgetRadio<T>(
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
