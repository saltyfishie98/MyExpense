import 'package:flutter/material.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';

class CategoryEditPage extends StatefulWidget {
  const CategoryEditPage({super.key});

  @override
  State createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends StateX<CategoryEditPage> {
  List<String> _categories = [];
  late MainController ctrlr;

  _CategoryEditPageState() : super(MainController()) {
    ctrlr = controller as MainController;
  }

  @override
  void initState() {
    super.initState();
    _categories = ctrlr.categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Categories:",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        size: 35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: double.infinity, height: 5),
                Expanded(
                  child: ReorderableListView(
                    children: [
                      for (int index = 0;
                          index < _categories.length;
                          index += 1)
                        ListTile(
                          minVerticalPadding: 17,
                          onLongPress: () {},
                          leading: const Icon(Icons.air),
                          title: Text(
                            _categories[index],
                          ),
                          trailing: Container(
                            margin: const EdgeInsets.only(right: 20),
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          key: Key(_categories[index]),
                        ),
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      setState(
                        () {},
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.close),
              ),
            )
          ],
        ),
      ),
    );
  }
}
