import 'package:flutter/material.dart';
import 'package:my_expense/controller.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/elements/widget_radio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:state_extended/state_extended.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

enum Graph { daily, monthly, yearly }

class _HomePageState extends StateX<HomePage> {
  Graph currentGraph = Graph.daily;
  late Controller ctrlr;

  _HomePageState() : super(Controller()) {
    ctrlr = controller as Controller;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elmtThemes = theme.extension<ElementThemes>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              //// Title ///////////////////////////////////////
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

              //// Graph ///////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: elmtThemes?.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 7,
                      color: elmtThemes?.shadow ?? Colors.black,
                    ),
                  ],
                ),
              ),

              //// Selection ///////////////////////////////////
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
                          title: "Daily",
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
                          title: "Monthly",
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
                          title: "Yearly",
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

              //// Entries /////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ListView.builder(
                      itemBuilder: (context, index) {
                        return StickyHeader(
                          header: Container(
                            width: double.infinity,
                            color: theme.canvasColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                "Day $index",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: elmtThemes?.h3Color,
                                ),
                              ),
                            ),
                          ),
                          content: Column(
                            children: [
                              _entry(context),
                              _entry(context),
                              _entry(context),
                              _entry(context),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () {
                          // HACK
                          ctrlr.addExpense(
                            Expense(
                                datetime: DateTime.now(),
                                amount: 100,
                                title: "Test",
                                category: "Sports"),
                          );
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

Widget _entry(BuildContext context) {
  final elmtThemes = Theme.of(context).extension<ElementThemes>();

  return Container(
    width: double.infinity,
    height: 75,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          const Text(
            "Expenses",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    ),
  );
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
