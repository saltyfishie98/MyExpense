import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/elements/entry_card.dart';
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

//// Home Page Widget //////////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

//// Home Page Widget States ///////////////////////////////////////////////////////////////////////

class _HomePageState extends StateX<HomePage> {
  GraphMode currentGraph = GraphMode.week;
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
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
            height: 300,
            child: Column(
              children: [
                const SizedBox(width: double.infinity, height: 30),
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

  final double _labelSize = 22;
  final double _tooltipFontSize = 12;
  final EdgeInsets _tooltipPadding = const EdgeInsets.symmetric(
    vertical: 5,
    horizontal: 10,
  );

  String _createTotalStr() {
    switch (graphType) {
      case GraphMode.week:
        final dailyTotal = controller.getThisWeekDailyTotal();
        return MainController.formatTotalStr(dailyTotal);

      case GraphMode.month:
        final weeklyTotal = controller.getThisMonthWeeklyTotal();
        return MainController.formatTotalStr(weeklyTotal);

      case GraphMode.year:
        final monthlyTotal = controller.getThisYearMonthlyTotal();
        return MainController.formatTotalStr(monthlyTotal);
    }
  }

  Widget _createChart(BuildContext context) {
    switch (graphType) {
      case GraphMode.week:
        return _weekChart(context);

      case GraphMode.month:
        return _monthChart(context);

      case GraphMode.year:
        return _yearChart(context);
    }
  }

  Widget _createChartLabel(BuildContext context) {
    switch (graphType) {
      case GraphMode.week:
        return _weekLabel();

      case GraphMode.month:
        return _monthLabel();

      case GraphMode.year:
        return _yearLabel();
    }
  }

  Widget _weekLabel() {
    final range = MainController.getThisWeekRange();

    final startMonth = DateFormat("MMM").format(range.start);
    final startDay = range.start.day.toString();

    final endMonth = DateFormat("MMM").format(range.end);
    final endDay = range.end.day.toString();

    Widget label(String dayLabel, String monthLabel) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: TextStyle(fontSize: _labelSize),
          ),
          Text(
            monthLabel,
            style: TextStyle(fontSize: _labelSize - 5),
          ),
        ],
      );
    }

    return Row(
      children: [
        label(startDay, startMonth),
        const Text(" - "),
        label(endDay, endMonth),
      ],
    );
  }

  Widget _monthLabel() {
    final monthStr = DateFormat("MMM, yyyy").format(DateTime.now());
    return Text(
      monthStr,
      style: TextStyle(fontSize: _labelSize),
    );
  }

  Widget _yearLabel() {
    final monthStr = DateFormat("Yr, yyyy").format(DateTime.now());
    return Text(
      monthStr,
      style: TextStyle(fontSize: _labelSize),
    );
  }

  Widget _lineChart(
    BuildContext context, {
    required List<int> totalList,
    double? xAxisLabelInterval,
    String Function(double)? xAxisLabelFormatter,
  }) {
    final theme = Theme.of(context).extension<ElementThemes>();
    final startBelowBarColor = Color(theme?.onCard.value ?? 0).withOpacity(0.4);
    final endBelowBarColor = Color(theme?.onCard.value ?? 0).withOpacity(0);

    var spots = <FlSpot>[];
    for (var i = 0; i < totalList.length; ++i) {
      spots.add(FlSpot(
        i.toDouble(),
        totalList[i] / 100.0,
      ));
    }

    List<LineChartBarData> lineData = [
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

    Widget labelBuider(double value, TitleMeta meta) {
      return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Text(
          xAxisLabelFormatter != null
              ? xAxisLabelFormatter(value)
              : value.toString(),
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: lineData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: xAxisLabelInterval,
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: xAxisLabelFormatter != null ? labelBuider : null,
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme?.accent,
            tooltipPadding: _tooltipPadding,
            getTooltipItems: (touchedSpots) {
              var out = <LineTooltipItem>[];

              for (final spotData in touchedSpots) {
                final tooltipLabel = xAxisLabelFormatter != null
                    ? xAxisLabelFormatter(spotData.x)
                    : "";

                out.add(
                  LineTooltipItem(
                    "$tooltipLabel:\n\$${spotData.y.toStringAsFixed(2)}",
                    TextStyle(
                      fontSize: _tooltipFontSize,
                    ),
                  ),
                );
              }

              return out;
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            final barStyle = FlLine(color: theme?.accent);
            final spotStyle = FlDotData(show: true);

            return spotIndexes
                .map((index) => TouchedSpotIndicatorData(
                      barStyle,
                      spotStyle,
                    ))
                .toList();
          },
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        minY: 0,
      ),
      key: UniqueKey(),
    );
  }

  Widget _yearChart(BuildContext context) {
    final totalList = controller.getThisYearMonthlyTotal();
    var months = List<String>.filled(totalList.length, "");

    months[0] = "Jan";
    months[1] = "Feb";
    months[2] = "Mar";
    months[3] = "Apr";
    months[4] = "May";
    months[5] = "Jun";
    months[6] = "Jul";
    months[7] = "Aug";
    months[8] = "Sep";
    months[9] = "Oct";
    months[10] = "Nov";
    months[11] = "Dec";

    return _lineChart(
      context,
      totalList: totalList,
      xAxisLabelFormatter: (value) => months[value.toInt()],
      xAxisLabelInterval: 3,
    );
  }

  Widget _monthChart(BuildContext context) {
    return _lineChart(
      context,
      totalList: controller.getThisMonthWeeklyTotal(),
      xAxisLabelInterval: 3,
      xAxisLabelFormatter: (value) => "${value.toInt() + 1}",
    );
  }

  Widget _weekChart(BuildContext context) {
    final dailyTotal =
        controller.getThisWeekDailyTotal().map((e) => e / 100.0).toList();

    final theme = Theme.of(context).extension<ElementThemes>();
    final gradientEnd = theme?.onCard.withOpacity(1);
    final gradientStart = theme?.onCard.withOpacity(0.5);
    final dateRange = MainController.getThisWeekRange();

    final days = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    final dateStrList = [
      for (var i = dateRange.start.day; i < dateRange.end.day; i++) i
    ];

    var barChartData = <BarChartGroupData>[];
    for (var i = 0; i < 7; ++i) {
      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal[i],
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
        ),
      );
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: _tooltipPadding,
            tooltipBgColor: theme?.accent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dateStr = dateStrList[groupIndex];
              final dayStr = days[groupIndex];
              return BarTooltipItem(
                "$dayStr $dateStr:\n\$${dailyTotal[groupIndex].toStringAsFixed(2)}",
                TextStyle(fontSize: _tooltipFontSize),
              );
            },
          ),
        ),
        alignment: BarChartAlignment.spaceBetween,
        barGroups: barChartData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 24,
              showTitles: true,
              getTitlesWidget: (value, meta) {
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
            const SizedBox(width: double.infinity, height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: _createChartLabel(context),
                ),
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
                      style: TextStyle(
                        fontSize: 30,
                        inherit: false,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: double.infinity, height: 20),
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
