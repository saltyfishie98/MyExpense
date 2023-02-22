import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late FToast fToast;

  _CategoryEditPageState() : super(MainController()) {
    ctrlr = controller as MainController;
  }

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

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

    void toAddCategoryPopup() {
      showDialog(
        context: context,
        builder: (context) {
          return CategoryEditPopup(
            controller: ctrlr,
            editController: titleInputCtrl,
            onCancel: () => Navigator.pop(context),
            onOk: () async {
              final success = await ctrlr.addCategory(
                Category(
                  title: titleInputCtrl.text,
                  color: Colors.blue,
                  icon: const Icon(Icons.check),
                  iconFamily: Icons.check.fontFamily!,
                  position: -1,
                ),
              );

              if (!success) {
                return Future(() => false);
              }

              setState(() {
                _categories = ctrlr.categories;
                Navigator.pop(context);
              });

              return Future(() => true);
            },
          );
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
          onPressed: toAddCategoryPopup,
          padding: EdgeInsets.zero,
          iconSize: 35,
          icon: const Icon(Icons.add),
        ),
      ],
    );

    final categoryList = Expanded(
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryListItem(
            key: Key(category.title),
            category: category,
            index: index,
            theme: theme,
            onLongPress: (category) {
              ctrlr.deleteCategory(category).then((_) {
                setState(() {
                  _categories = ctrlr.categories;
                });
              });
            },
          );
        },
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
      ),
    );

    final closeBtn = Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: FloatingActionButton(
        onPressed: () {
          if (_categories.isEmpty) {
            final toast = Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: themeExt?.accent,
              ),
              child: const Text("Categories can't be empty!"),
            );

            fToast.showToast(
              child: toast,
              toastDuration: const Duration(seconds: 2),
              gravity: ToastGravity.CENTER,
            );
            return;
          }

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

class _CategoryListItem extends StatelessWidget {
  const _CategoryListItem({
    super.key,
    required this.category,
    required this.index,
    required this.theme,
    required this.onLongPress,
  });

  final Category category;
  final ThemeData theme;
  final Function(Category) onLongPress;
  final int index;

  @override
  Widget build(BuildContext context) {
    final themeExt = theme.extension<ElementThemes>();

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          themeExt?.cardRadius ?? 10,
        ),
      ),
      onLongPress: () {
        onLongPress(category);
      },
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
  }
}

class CategoryEditPopup extends StatefulWidget {
  const CategoryEditPopup({
    super.key,
    required this.controller,
    required this.onOk,
    required this.editController,
    required this.onCancel,
  });

  final MainController controller;
  final Future<bool> Function() onOk;
  final Function() onCancel;
  final TextEditingController editController;

  @override
  State<CategoryEditPopup> createState() => _CategoryEditPopupState();
}

class _CategoryEditPopupState extends State<CategoryEditPopup> {
  var addCategoryTextFieldFocus = FocusNode();
  var okDisable = true;
  var categoryError = false;

  @override
  void dispose() {
    super.dispose();
    addCategoryTextFieldFocus.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.editController.addListener(() {
      setState(() {
        if (widget.editController.text.isEmpty) {
          okDisable = true;
        } else {
          okDisable = false;
        }
        categoryError = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleInputCtrl = widget.editController;
    FocusScope.of(context).requestFocus(addCategoryTextFieldFocus);

    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextField(
          focusNode: addCategoryTextFieldFocus,
          controller: titleInputCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "New Category",
            errorText: categoryError ? "Category already exist!" : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: okDisable
              ? null
              : () async {
                  final success = await widget.onOk();
                  if (!success) {
                    setState(() {
                      categoryError = true;
                    });
                  }
                },
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
