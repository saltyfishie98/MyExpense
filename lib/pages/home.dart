import 'package:flutter/material.dart';
import 'package:my_expense/theme.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void onPressed() {}

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
              //// Title Bar ////////////////////////////////////////
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

              //// Graph ////////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Container(
                width: double.infinity,
                height: 175,
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

              //// Selector /////////////////////////////////////////
              const SizedBox(width: double.infinity, height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: elmtThemes?.subsurface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              //// Categories ///////////////////////////////////////
              const SizedBox(width: double.infinity, height: 15),
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ListView.builder(
                      // itemCount: 10,
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
                        onPressed: () {},
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
      // color: Colors.amber,
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
                )
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
