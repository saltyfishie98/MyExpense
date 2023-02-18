import 'package:flutter/material.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';
import 'package:tuple/tuple.dart';

typedef EntryRow = Tuple3<String, Widget, double>;

class ExpenseEntry extends StatefulWidget {
  const ExpenseEntry({super.key});

  @override
  State createState() => _ExpenseEntryState();
}

class _ExpenseEntryState extends StateX<ExpenseEntry> {
  late MainController ctrlr;
  String selectedCategory = "text";

  _ExpenseEntryState() : super(MainController()) {
    ctrlr = controller as MainController;
  }

  Widget entryField() {
    return const SizedBox(
      height: 30,
      width: 100,
      child: TextField(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            width: double.infinity,
            height: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add\nExpense:",
                  style: TextStyle(fontSize: 40),
                  maxLines: 2,
                ),
                const SizedBox(width: double.infinity, height: 30),
                _entrySecction(
                  [
                    EntryRow(
                      "Title",
                      entryField(),
                      0,
                    ),
                    EntryRow(
                        "Category",
                        DropdownButton<String>(
                          value: ctrlr.categories.first,
                          items: ctrlr.categories.map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                          onChanged: (category) {
                            selectedCategory = category!;
                          },
                        ),
                        0),
                    const EntryRow("Date", Placeholder(), 0),
                    EntryRow("Amount", entryField(), 20),
                  ],
                  rowHeight: 30,
                ),
                const SizedBox(width: double.infinity, height: 90),
                Center(
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Size _textSize(Text text) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text.data, style: text.style),
    maxLines: text.maxLines,
    textDirection: text.textDirection,
  )..layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );
  return textPainter.size;
}

Widget _entrySecction(List<EntryRow> rows, {required double rowHeight}) {
  List<Widget> rowList = [];
  List<double> rowLabelWidths = [];
  late Text rowLabel;

  Text createLabel(String label) {
    return Text(
      "$label:",
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: rowHeight - 7),
      textDirection: TextDirection.ltr,
    );
  }

  for (final row in rows) {
    rowLabel = createLabel(row.item1);
    rowLabelWidths.add(_textSize(rowLabel).width + 2);

    if (rowLabelWidths.length > 1) {
      rowLabelWidths.sort((a, b) => b.compareTo(a));
    }
  }

  for (final row in rows) {
    final label = createLabel(row.item1);

    rowList.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: rowHeight + row.item3,
            width: rowLabelWidths.first,
            child: Align(alignment: FractionalOffset.bottomRight, child: label),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 4),
              height: rowHeight + row.item3,
              child: row.item2,
            ),
          ),
        ],
      ),
    ));
  }

  return Column(
    children: rowList,
  );
}
