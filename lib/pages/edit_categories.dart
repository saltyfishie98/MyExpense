import 'package:flutter/material.dart';
import 'package:my_expense/data/controller.dart';
import 'package:my_expense/theme.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = await ctrlr.getCategories();
      setState(() {
        _categories = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<ElementThemes>();
    var titleInputCtrl = TextEditingController();

    void toEditCategoryPopup() {
      Widget editPanel = AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            controller: titleInputCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "New Category",
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctrlr.addCategory(
                Category(
                  title: titleInputCtrl.text,
                  color: Colors.blue,
                  icon: const Icon(Icons.check),
                  position: -1,
                ),
              );
              setState(() {
                _categories = ctrlr.categories;
              });
              Navigator.pop(context);
            },
            child: const Text("Ok"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      );

      showDialog(
        context: context,
        builder: (context) {
          return editPanel;
        },
      );
    }

    final header = Row(
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
    );

    final categoryList = Expanded(
      child: ReorderableListView.builder(
        itemBuilder: (context, index) {
          final category = _categories[index];
          return InkWell(
            key: Key(category.title),
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                themeExt?.cardRadius ?? 10,
              ),
            ),
            onLongPress: () {},
            child: ListTile(
              minVerticalPadding: 17,
              leading: category.icon,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title,
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded),
              ),
            ),
          );
        },
        itemCount: _categories.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(
            () {
              final item = _categories.removeAt(oldIndex);

              if (oldIndex > newIndex) {
                _categories.insert(newIndex, item);
              } else {
                _categories.insert(newIndex - 1, item);
              }
            },
          );
        },
        buildDefaultDragHandles: false,
      ),
    );

    final closeBtn = Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: FloatingActionButton(
        onPressed: () {
          for (var i = 0; i < _categories.length; ++i) {
            _categories[i] = _categories[i].copyWith(position: i);
          }
          ctrlr.updateCategories(_categories);
          Navigator.pop(context);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.check),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  header,
                  const SizedBox(width: double.infinity, height: 5),
                  categoryList,
                ],
              ),
              closeBtn,
            ],
          ),
        ),
      ),
    );
  }
}
