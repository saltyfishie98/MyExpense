import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:my_expense/elements/entry_card.dart';
import 'package:my_expense/elements/expense_overview.dart';
import 'package:my_expense/elements/modify_prompt.dart';
import 'package:my_expense/pages/settings.dart';
import 'package:state_extended/state_extended.dart';
import 'package:my_expense/data/controller.dart';
import 'package:my_expense/pages/expense_entry.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/elements/radio_option.dart';

//// Home Page Widget //////////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

//// Home Page Widget States ///////////////////////////////////////////////////////////////////////

class _HomePageState extends StateX<HomePage> {
  ExpenseOverviewType currentGraph = ExpenseOverviewType.week;
  late MainController ctrlr;
  ExpenseOverview? chartView;

  _HomePageState() : super(MainController()) {
    ctrlr = controller as MainController;
    chartView = ExpenseOverview(
      controller: ctrlr,
      overviewType: currentGraph,
    );
  }

  @override
  void initState() {
    super.initState();
    ctrlr.onHomeWidgetLaunched(launchFromWidgetCallback);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ctrlr.sendHomeWidget(
      MainController.formatTotalAmountForView(
        ctrlr.getThisMonthWeeklyTotal(),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(width: double.infinity, height: 10),
              headerLogo(theme),
              const SizedBox(width: double.infinity, height: 15),
              chartView!,
              const SizedBox(width: double.infinity, height: 20),
              radioSelector(theme),
              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: SizedBox(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      dailyEntryView(theme),
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

  //// Header Logo /////////////////////////////////////////////////////////////////////////////////

  Widget headerLogo(ThemeData theme) {
    Widget page(BuildContext context) {
      return const SettingsPage();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "JustExpense",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: page));
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              const CircleBorder(),
            ),
          ),
          child: const Icon(
            Icons.settings,
          ),
        ),
      ],
    );
  }

  //// Selection ///////////////////////////////////////////////////////////////////////////////////

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

  Widget radioSelector(ThemeData theme) {
    var radioOptions = <Widget>[];
    final elmtThemes = theme.extension<ElementThemes>();

    for (final mode in ExpenseOverviewType.values) {
      radioOptions.add(
        Expanded(
          child: _radioOption(
            context,
            title: mode.toLabelString(),
            value: mode,
            groupValue: currentGraph,
            onChanged: (current) => setState(() {
              currentGraph = current!;
              chartView = ExpenseOverview(
                controller: ctrlr,
                overviewType: currentGraph,
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

  //// Daily Entries Section View //////////////////////////////////////////////////////////////////

  Widget dailyEntryView(ThemeData theme) {
    void toEditExpense(Expense expense) {
      final page = PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _transition,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExpenseEntryPage(
          "Edit\nExpense:",
          onNewExpense: null,
          onEditExpense: () {
            setState(() {
              chartView = ExpenseOverview(
                controller: ctrlr,
                overviewType: currentGraph,
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
        chartView = ExpenseOverview(
          controller: ctrlr,
          overviewType: currentGraph,
        );
      });
    }

    void showModifyPrompt(Expense expense) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return createModifyPrompt(context, options: [
            promptButton("Edit", context, onTap: () {
              Navigator.pop(context);
              toEditExpense(expense);
            }),
            promptButton("Delete", context, onTap: () {
              Navigator.pop(context);
              toDeleteExpense(expense);
            }),
          ]);
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
                onLongPress: showModifyPrompt,
              ),
              childCount: data.length,
            ),
          ),
        ),
      );
    }

    return CustomScrollView(slivers: sliverList);
  }

  //// Add Entry Button ////////////////////////////////////////////////////////////////////////////

  Widget addEntryButton() {
    void toAddExpense() async {
      final page = PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _transition,
        pageBuilder: (context, animation, secondaryAnimation) =>
            createExpenseEntryPage(),
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

  //// Misc ////////////////////////////////////////////////////////////////////////////////////////

  Widget createExpenseEntryPage() {
    return ExpenseEntryPage(
      "Add\nExpense:",
      onNewExpense: () {
        setState(() {
          chartView = ExpenseOverview(
            controller: ctrlr,
            overviewType: currentGraph,
          );
        });
      },
      onEditExpense: null,
    );
  }

  void launchFromWidgetCallback(Uri? uri) {
    if (uri != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return createExpenseEntryPage();
      }));
    }
  }
}

Widget _transition(context, animation, secondaryAnimation, child) {
  const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  final tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
  final offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
  );
}
