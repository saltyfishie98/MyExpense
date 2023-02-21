import 'package:flutter/material.dart';
import 'package:my_expense/pages/edit_categories.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _button(String label, {required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: double.infinity, height: 300),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _button("Edit Categories.", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoryEditPage(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: double.infinity, height: 100),
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
    );
  }
}
