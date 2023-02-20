import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:my_expense/elements/entry_card.dart';
import 'package:state_extended/state_extended.dart';
import 'package:my_expense/controller.dart';
import 'package:my_expense/pages/expense_entry.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/elements/radio_option.dart';
import 'dart:math' as math;

enum GraphMode { daily, monthly }

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

//// Home Page Widget //////////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

//// Home Page Widget States ///////////////////////////////////////////////////////////////////////

class _HomePageState extends StateX<HomePage> {
  GraphMode currentGraph = GraphMode.daily;
  late MainController ctrlr;
  ExpenseChart? chartView;

  _HomePageState() : super(MainController()) {
    ctrlr = controller as MainController;
    chartView = ExpenseChart(
      controller: ctrlr,
      graphType: currentGraph,
    );
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
              chartView = ExpenseChart(
                controller: ctrlr,
                graphType: currentGraph,
              );
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
    void toEditExpense(Expense expense) {
      final page = MaterialPageRoute(
        builder: (context) => ExpenseEntry(
          "Edit\nExpense:",
          onNewExpense: null,
          onEditExpense: () {
            setState(() {
              chartView = ExpenseChart(
                controller: ctrlr,
                graphType: currentGraph,
              );
            });
          },
          expense: expense,
        ),
      );

      Navigator.push(context, page);
    }

    void toDeleteExpense(Expense expense) {
      setState(() {
        ctrlr.deleteExpense(expense);
        chartView = ExpenseChart(
          controller: ctrlr,
          graphType: currentGraph,
        );
      });
    }

    void toModifyPrompt(Expense expense) {
      Widget button(String label, {required Function() onTap}) {
        return InkWell(
          onTap: onTap,
          child: SizedBox(
            child: Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            height: 175,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button("Edit", onTap: () {
                  Navigator.pop(context);
                  toEditExpense(expense);
                }),
                button("Delete", onTap: () {
                  Navigator.pop(context);
                  toDeleteExpense(expense);
                }),
              ],
            ),
          );
        },
      );
    }

    var sliverList = <SliverStickyHeader>[];

    for (var i = 0; i < ctrlr.dailySectionsCount; ++i) {
      final data = ctrlr.dailyDataAt(i);

      sliverList.add(
        SliverStickyHeader(
          header: Container(
            color: theme.canvasColor,
            child: Text(
              MainController.formatDateString(data.first.datetime),
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => createEntryCard(
                context,
                expense: data[i],
                onLongPress: toModifyPrompt,
              ),
              childCount: data.length,
            ),
          ),
        ),
      );
    }

    return CustomScrollView(slivers: sliverList);
  }

  Widget addEntryButton() {
    void toAddExpense() async {
      final page = MaterialPageRoute(
        builder: (context) => ExpenseEntry(
          "Add\nExpense:",
          onNewExpense: () {
            setState(() {
              chartView = ExpenseChart(
                controller: ctrlr,
                graphType: currentGraph,
              );
            });
          },
          onEditExpense: null,
        ),
      );

      Navigator.push(context, page);
    }

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
              chartView!,

              //// Selection ///////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 20),
              radioSelector(theme),

              //// Entries /////////////////////////////////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: SizedBox(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      //// Daily Entries Section View ////////////////////////////////////////////////
                      dailyEntryView(theme),

                      //// Add Entry Button //////////////////////////////////////////////////////////
                      addEntryButton(),
                    ],
                  ),
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

//// Expense Chart /////////////////////////////////////////////////////////////////////////////////

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({
    super.key,
    required this.controller,
    required this.graphType,
  });

  final MainController controller;
  final GraphMode graphType;

  String _createTotalStr() {
    switch (graphType) {
      case GraphMode.daily:
        final dailyTotal = controller.getThisWeekDailyTotal();
        return (dailyTotal.reduce((a, b) => a + b) / 100).toStringAsFixed(2);

      case GraphMode.monthly:
        final monthlyTotal = controller.getThisYearMonthlyTotal();
        return (monthlyTotal.reduce((a, b) => a + b) / 100).toStringAsFixed(2);
    }
  }

  Widget _createChart(BuildContext context) {
    switch (graphType) {
      case GraphMode.daily:
        return _dailyChart(context);

      case GraphMode.monthly:
        return _monthlyChart(context);
    }
  }

  Widget _monthlyChart(BuildContext context) {
    final monthlyTotal = controller.getThisYearMonthlyTotal();

    List<LineChartBarData> lineData() {
      var spots = <FlSpot>[];

      for (var i = 0; i < 12; ++i) {
        spots.add(FlSpot(i.toDouble(), monthlyTotal[i] / 100.0));
      }

      final theme = Theme.of(context).extension<ElementThemes>();

      final startBelowBarColor =
          Color(theme?.onCard.value ?? 0).withOpacity(0.4);
      final endBelowBarColor = Color(theme?.onCard.value ?? 0).withOpacity(0);

      return [
        LineChartBarData(
          spots: spots,
          color: theme?.onCard,
          isCurved: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [startBelowBarColor, endBelowBarColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          shadow: Shadow(
            blurRadius: 15,
            color: theme?.shadow.withOpacity(0.3) ?? Colors.black26,
            offset: const Offset(0, 10),
          ),
        )
      ];
    }

    return LineChart(
      LineChartData(
        lineBarsData: lineData(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 3,
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec",
                ];

                return Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Text(
                    months[value.toInt()],
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
        minY: 0,
      ),
    );
  }

  Widget _dailyChart(BuildContext context) {
    final dailyTotal = controller.getThisWeekDailyTotal();

    final theme = Theme.of(context).extension<ElementThemes>();
    final gradientStart = theme?.onCard.withOpacity(1);
    final gradientEnd = theme?.onCard.withOpacity(0.3);

    List<BarChartGroupData> barChartData() {
      var out = <BarChartGroupData>[];

      for (var i = 0; i < 7; ++i) {
        out.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal[i].toDouble() / 100,
              gradient: LinearGradient(
                colors: [
                  gradientStart ?? Colors.green.shade400,
                  gradientEnd ?? Colors.green.shade400.withOpacity(0.3)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          ],
        ));
      }

      return out;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        barGroups: barChartData(),
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
    );
  }

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
                  "\$${_createTotalStr()}",
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
            const SizedBox(width: double.infinity, height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: _createChart(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
