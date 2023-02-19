import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/controller.dart';
import 'package:state_extended/state_extended.dart';
import 'package:tuple/tuple.dart';

typedef EntryRow = Tuple3<String, Widget, double>;

class ExpenseEntry extends StatefulWidget {
  const ExpenseEntry(
    this.label, {
    super.key,
    required this.onNewExpense,
    required this.onEditExpense,
    this.expense,
  });

  final String label;
  final Function()? onNewExpense;
  final Function()? onEditExpense;
  final Expense? expense;

  double get labelFontSize => _labelFontSize;
  int get entryFlexValue => _entryFlexValue;
  int get labelFlexValue => _labelFlexValue;

  final double _labelFontSize = 22;
  final int _entryFlexValue = 5;
  final int _labelFlexValue = 3;

  @override
  State createState() => _ExpenseEntryState();
}

class _ExpenseEntryState extends StateX<ExpenseEntry> {
  //// States ///////////////////////////////////////////////

  String _selectedCategory = "";
  DateTime _selectedDate = DateTime.now();
  bool _titleFilled = true;
  bool _amountFilled = true;
  late MainController _ctrlr;

  //// Implementations //////////////////////////////////////

  _ExpenseEntryState() : super(MainController()) {
    _ctrlr = controller as MainController;
    _selectedCategory = _ctrlr.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final entryFontSize = widget.labelFontSize - 2;
    final entryCellHeight = widget.labelFontSize + 10;
    const double entrySpacing = 17;

    late TextEditingController titleInputCtrl;
    late TextEditingController amountInputCtrl;

    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.datetime;
      titleInputCtrl = TextEditingController(text: widget.expense!.title);
      amountInputCtrl = TextEditingController(
        text: (widget.expense!.amount / 100).toStringAsFixed(2),
      );
    } else {
      titleInputCtrl = TextEditingController();
      amountInputCtrl = TextEditingController();
    }

    void addExpenseCallback() async {
      final emptyTitle = titleInputCtrl.text.isEmpty;
      final emptyAmount = amountInputCtrl.text.isEmpty;

      if (emptyTitle || emptyAmount) {
        setState(() {
          emptyTitle ? _titleFilled = false : _titleFilled = true;
          emptyAmount ? _amountFilled = false : _amountFilled = true;
        });
        return;
      }

      Navigator.pop(context);
      await _ctrlr.addExpense(
        Expense(
          datetime: _selectedDate,
          amount: MainController.formatAmountToInsert(
              double.parse(amountInputCtrl.text)),
          title: titleInputCtrl.text,
          category: _selectedCategory,
        ),
      );

      widget.onNewExpense!();
    }

    void editExpenseCallback() async {
      final emptyTitle = titleInputCtrl.text.isEmpty;
      final emptyAmount = amountInputCtrl.text.isEmpty;

      if (emptyTitle || emptyAmount) {
        setState(() {
          emptyTitle ? _titleFilled = false : _titleFilled = true;
          emptyAmount ? _amountFilled = false : _amountFilled = true;
        });
        return;
      }

      Navigator.pop(context);

      await _ctrlr.editExpense(
        oldExpense: widget.expense!,
        newExpense: Expense(
          title: titleInputCtrl.text,
          amount: MainController.formatAmountToInsert(
            double.parse(amountInputCtrl.text),
          ),
          category: _selectedCategory,
          datetime: _selectedDate,
        ),
      );

      widget.onEditExpense!();
    }

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  //// Add Expense //////////////////////////////

                  alignment: FractionalOffset.topLeft,
                  child: Text(
                    widget.label,
                    maxLines: 2,
                    style: const TextStyle(
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
                        flex: widget.labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Title:",
                            maxLines: 1,
                            style: TextStyle(fontSize: widget.labelFontSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: widget.entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          height: entryCellHeight,
                          child: TextField(
                            controller: titleInputCtrl,
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
                      _entryErrorWidget(
                        !_titleFilled,
                        boxSize: Size(10, entryCellHeight),
                      )
                    ],
                  ),

                  //// Category Select //////////////////////////

                  const SizedBox(width: double.infinity, height: entrySpacing),
                  Row(
                    children: [
                      Expanded(
                        flex: widget.labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Category:",
                            maxLines: 1,
                            style: TextStyle(fontSize: widget.labelFontSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: widget.entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 0),
                          height: entryCellHeight,
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: const Icon(
                                Icons.arrow_drop_down_circle_outlined),
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
                        flex: widget.labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Date:",
                            maxLines: 1,
                            style: TextStyle(fontSize: widget.labelFontSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: widget.entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 0),
                          height: entryCellHeight,
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
                        flex: widget.labelFlexValue,
                        child: Align(
                          alignment: FractionalOffset.centerRight,
                          child: Text(
                            "Amount:",
                            maxLines: 1,
                            style: TextStyle(fontSize: widget.labelFontSize),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: widget.entryFlexValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          height: entryCellHeight + 50,
                          child: TextField(
                            controller: amountInputCtrl,
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
                      ),
                      _entryErrorWidget(
                        !_amountFilled,
                        boxSize: Size(10, entryCellHeight),
                      )
                    ],
                  ),
                ],
              ),

              //// Check Mark Button ///////////////////////////////

              const SizedBox(width: double.infinity, height: 0),
              FloatingActionButton(
                heroTag: "add-button",
                onPressed: widget.expense == null
                    ? addExpenseCallback
                    : editExpenseCallback,
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

Widget _entryErrorWidget(bool visibilityValue, {required Size boxSize}) {
  return Align(
    alignment: FractionalOffset.centerLeft,
    child: SizedBox(
      height: boxSize.height,
      width: boxSize.width,
      child: Visibility(
        visible: visibilityValue,
        child: const Text(
          "!",
          style: TextStyle(
            fontSize: 25,
            color: Colors.red,
          ),
        ),
      ),
    ),
  );
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
