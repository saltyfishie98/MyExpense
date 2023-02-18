import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double labelSize = 22;
  int entryFlexValue = 5;
  int labelFlexValue = 3;

  _ExpenseEntryState() : super(MainController()) {
    ctrlr = controller as MainController;
    selectedCategory = ctrlr.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final entryFontSize = labelSize - 2;
    final entrySize = labelSize + 10;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Align(
                  //// Add Expense //////////////////////////////
                  alignment: FractionalOffset.topLeft,
                  child: Text(
                    "Add\nExpense:",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w500,
                    ),
                  )),

              Column(
                children: [
                  //// Title ////////////////////////////////////
                  Row(
                    children: [
                      Expanded(
                        flex: labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Title:",
                            maxLines: 1,
                            style: TextStyle(fontSize: labelSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 20),
                          height: entrySize,
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 5),
                            ),
                            style: TextStyle(fontSize: entryFontSize),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //// Category Select //////////////////////////
                  const SizedBox(width: double.infinity, height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Category:",
                            maxLines: 1,
                            style: TextStyle(fontSize: labelSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 0),
                          height: entrySize,
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            underline: const SizedBox(),
                            isExpanded: true,
                            onChanged: (String? value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                            items:
                                ctrlr.categories.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: entryFontSize,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      )
                    ],
                  ),

                  //// Date /////////////////////////////////////
                  const SizedBox(width: double.infinity, height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Date:",
                            maxLines: 1,
                            style: TextStyle(fontSize: labelSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 0),
                          height: entrySize,
                          child: GestureDetector(
                            onTap: () {
                              Feedback.forTap(context);
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              ).then((pickedDate) {
                                if (pickedDate != null) {
                                  setState(() => _selectedDate = pickedDate);
                                }
                              });
                            },
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate),
                                  style: TextStyle(fontSize: entryFontSize),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //// Amount ///////////////////////////////////
                  const SizedBox(width: double.infinity, height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Amount:",
                            maxLines: 1,
                            style: TextStyle(fontSize: labelSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 20),
                          height: entrySize + 50,
                          child: TextField(
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 5),
                            ),
                            style: TextStyle(fontSize: entryFontSize + 20),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp("[0-9]"),
                              ),
                              PriceFormatter(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),

              //// Back Button //////////////////////////////
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

Size _textSize(Text text) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text.data, style: text.style),
    maxLines: text.maxLines,
    textDirection: ui.TextDirection.ltr,
  )..layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );
  return textPainter.size;
}

class PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == "0") return oldValue;
    if (newValue.text.length > 3) {
      var amount = double.parse(newValue.text);
      amount = amount / 100;

      final out = TextEditingValue(
        text: amount.toString(),
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
      return out;
    }
    if (newValue.text.length == 3) {
      var amount = double.parse(newValue.text);
      amount = amount / 10;

      final out = TextEditingValue(
        text: amount.toString(),
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
      return out;
    }
    return newValue;
  }
}
