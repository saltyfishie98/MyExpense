import 'package:flutter/material.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';

class CategoryEditPage extends StatefulWidget {
  const CategoryEditPage({super.key});

  @override
  State createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends StateX<CategoryEditPage> {
  List<Category> _categories = [];
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
    var categoryTiles = <Widget>[];
    var titleInputCtrl = TextEditingController();

    for (var category in _categories) {
      categoryTiles.add(
        ListTile(
          minVerticalPadding: 17,
          onLongPress: () {},
          leading: category.icon,
          title: Text(
            category.title,
          ),
          trailing: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          key: Key(category.title),
        ),
      );
    }

    void toEditCategoryPopup() {
      Widget editPanel = Center(
        child: Column(
          children: [
            TextField(
              controller: titleInputCtrl,
            ),
            FloatingActionButton(
              onPressed: () {
                final test = Category(
                  title: titleInputCtrl.text,
                  color: Colors.blue,
                  icon: const Icon(Icons.check),
                  position: 0,
                );

                ctrlr.addCategory(test).then((value) {
                  setState(() {
                    _categories = ctrlr.categories;
                  });
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      );

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return editPanel;
        },
      );

      // const test = Category(
      //   title: "Test",
      //   color: Colors.blue,
      //   icon: Icon(Icons.check),
      //   position: 0,
      // );

      // await ctrlr.addCategory(test);

      // setState(() {
      //   _categories = ctrlr.categories;
      // });
    }

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
                      onPressed: toEditCategoryPopup,
                      padding: EdgeInsets.zero,
                      iconSize: 35,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(width: double.infinity, height: 5),
                Expanded(
                  child: ReorderableListView(
                    children: categoryTiles,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(
                        () {
                          final item = _categories.removeAt(oldIndex);
                          _categories.insert(newIndex, item);
                        },
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
                  for (var i = 0; i < _categories.length; ++i) {
                    _categories[i] = _categories[i].copyWith(position: i);
                  }
                  ctrlr.updateCategories();
                  Navigator.pop(context);
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.check),
              ),
            )
          ],
        ),
      ),
    );
  }
}
