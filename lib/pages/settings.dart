import 'package:flutter/material.dart';
import 'package:my_expense/elements/modify_prompt.dart';
import 'package:my_expense/pages/edit_categories.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        promptButton("Edit Categories", context, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryEditPage(),
                            ),
                          );
                        }),
                        promptButton("Licenses", context, onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: "MyExpense",
                          );
                        })
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
