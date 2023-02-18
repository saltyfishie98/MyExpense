import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';
import 'package:tuple/tuple.dart';
import 'dart:ui' as ui;

typedef EntryRow = Tuple3<String, Widget, double>;

class ExpenseEntry extends StatefulWidget {
  const ExpenseEntry({super.key});

  @override
  State createState() => _ExpenseEntryState();
}

class _ExpenseEntryState extends StateX<ExpenseEntry> {
  late MainController ctrlr;
  String selectedCategory = "";
  DateTime _selectedDate = DateTime.now();

  _ExpenseEntryState() : super(MainController()) {
    ctrlr = controller as MainController;
    selectedCategory = ctrlr.categories.first;
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
                _entrySection(
                  [
                    //// Title ////////////////////////////////////
                    EntryRow(
                      "Title",
                      entryField(),
                      0,
                    ),

                    //// Category Select /////////////////////////
                    EntryRow(
                      "Category",
                      _categorySelection(
                        context,
                        controller: ctrlr,
                        selectedCategory: selectedCategory,
                        onChanged: (category) => setState(() {
                          selectedCategory = category!;
                        }),
                      ),
                      0,
                    ),

                    //// Date Select ////////////////////////////
                    EntryRow(
                      "Date",
                      _dateSelection(
                        context,
                        value: _selectedDate,
                        onSelected: (pickedDate) => setState(() {
                          _selectedDate = pickedDate;
                        }),
                      ),
                      0,
                    ),

                    //// Amount Entry ///////////////////////////
                    EntryRow(
                      "Amount",
                      entryField(),
                      20,
                    ),
                  ],
                  labelSize: 25,
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

Widget _dateSelection(
  BuildContext context, {
  required DateTime value,
  required Function(DateTime) onSelected,
}) {
  return GestureDetector(
    child: SizedBox(
      height: double.infinity,
      child: Text(DateFormat('dd MMM yyyy').format(value)),
    ),
    onTap: () {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
      ).then((pickedDate) {
        if (pickedDate != null) {
          onSelected(pickedDate);
        }
      });
    },
  );
}

Widget _categorySelection(
  BuildContext context, {
  required Function(String?) onChanged,
  required MainController controller,
  required String selectedCategory,
}) {
  return DropdownButton<String>(
    isDense: true,
    value: selectedCategory,
    items: controller.categories.map<DropdownMenuItem<String>>(
      (String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      },
    ).toList(),
    onChanged: onChanged,
  );
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

Widget _entrySection(List<EntryRow> rows, {required double labelSize}) {
  List<Widget> rowList = [];
  List<double> rowLabelWidths = [];
  late double rowLabelHeight;
  late Text rowLabel;

  Text createLabel(String label) {
    return Text(
      "$label:",
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: labelSize),
      textDirection: ui.TextDirection.ltr,
    );
  }

  for (final row in rows) {
    rowLabel = createLabel(row.item1);
    rowLabelWidths.add(_textSize(rowLabel).width + 2);

    if (rowLabelWidths.length > 1) {
      rowLabelWidths.sort((a, b) => b.compareTo(a));
    }
  }

  rowLabelHeight = _textSize(rowLabel).height + 5;

  for (final row in rows) {
    final label = createLabel(row.item1);

    rowList.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: rowLabelHeight + row.item3,
            width: rowLabelWidths.first,
            child: Align(alignment: FractionalOffset.bottomRight, child: label),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 4),
              height: rowLabelHeight + row.item3,
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
