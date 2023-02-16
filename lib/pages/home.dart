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
    final elmtColors = Theme.of(context).extension<ElementColors>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(width: double.infinity, height: 10),

              // Title Bar
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

              const SizedBox(width: double.infinity, height: 15),

              // Graph
              Container(
                width: double.infinity,
                height: 175,
                decoration: BoxDecoration(
                  color: elmtColors?.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          elmtColors != null ? elmtColors.shadow : Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: double.infinity, height: 20),

              Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                    color: theme.highlightColor,
                    borderRadius: BorderRadius.circular(15)),
              ),

              const SizedBox(width: double.infinity, height: 15),

              // Category Title
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Expense",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Categories
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
                              child: Text("Day $index"),
                            ),
                          ),
                          content: Column(
                            children: [
                              _entry(theme),
                              _entry(theme),
                              _entry(theme),
                              _entry(theme),
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

Widget _entry(ThemeData theme) {
  return Container(
    width: double.infinity,
    height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
