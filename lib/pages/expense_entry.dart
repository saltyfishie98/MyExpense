import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';
import 'package:tuple/tuple.dart';

typedef EntryRow = Tuple3<String, Widget, double>;

class ExpenseEntry extends StatefulWidget {
  const ExpenseEntry({
    super.key,
    required this.onNewExpense,
  });

  final Function() onNewExpense;
  @override
  State createState() => _ExpenseEntryState();
}

class _ExpenseEntryState extends StateX<ExpenseEntry> {
  double labelSize = 22;
  int entryFlexValue = 5;
  int labelFlexValue = 3;

  //// States ///////////////////////////////////////////////

  String _selectedCategory = "";
  DateTime _selectedDate = DateTime.now();
  late MainController _ctrlr;
  final _titleInputCtrl = TextEditingController();
  final _amountInputCtrl = TextEditingController();

  //// Implementations //////////////////////////////////////

  _ExpenseEntryState() : super(MainController()) {
    _ctrlr = controller as MainController;
    _selectedCategory = _ctrlr.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final entryFontSize = labelSize - 2;
    final entrySize = labelSize + 10;
    const double entrySpacing = 17;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 600,
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
                            controller: _titleInputCtrl,
                            textCapitalization: TextCapitalization.sentences,
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

                  const SizedBox(width: double.infinity, height: entrySpacing),
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
                            value: _selectedCategory,
                            underline: const SizedBox(),
                            isExpanded: true,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                            items:
                                _ctrlr.categories.map<DropdownMenuItem<String>>(
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

                  const SizedBox(width: double.infinity, height: entrySpacing),
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
                            onTap: () async {
                              Feedback.forTap(context);
                              var pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate == null) {
                                return;
                              }

                              final now = DateTime.now();
                              if (pickedDate.year == now.year &&
                                  pickedDate.month == now.month &&
                                  pickedDate.day == now.day) {
                                pickedDate = now;
                              }

                              setState(() => _selectedDate = pickedDate!);
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

                  const SizedBox(
                      width: double.infinity,
                      height: entrySpacing == 0 ? 0 : entrySpacing - 10),
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
                            controller: _amountInputCtrl,
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

              //// Add Button ///////////////////////////////

              const SizedBox(width: double.infinity, height: 0),
              FloatingActionButton(
                heroTag: "add-button",
                onPressed: () async {
                  Navigator.pop(context);
                  await _ctrlr.addExpense(
                    Expense(
                      datetime: _selectedDate,
                      amount:
                          (double.parse(_amountInputCtrl.text) * 100).toInt(),
                      title: _titleInputCtrl.text,
                      category: _selectedCategory,
                    ),
                  );
                  widget.onNewExpense();
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.check),
              ),

              //// Back Button //////////////////////////////

              FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                shape: const CircleBorder(),
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        text: amount.toStringAsFixed(2),
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
      return out;
    }
    if (newValue.text.length == 3) {
      var amount = double.parse(newValue.text);
      amount = amount / 10;

      final out = TextEditingValue(
        text: amount.toStringAsFixed(1),
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
      return out;
    }
    return newValue;
  }
}
