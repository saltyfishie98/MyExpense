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

  String _selectedCategoryStr = "";
  DateTime _selectedDate = DateTime.now();
  bool _titleFilled = true;
  bool _amountFilled = true;
  TextEditingController titleInputCtrl = TextEditingController();
  TextEditingController amountInputCtrl = TextEditingController(text: "0.00");
  late MainController _ctrlr;

  //// Implementations //////////////////////////////////////

  _ExpenseEntryState() : super(MainController()) {
    _ctrlr = controller as MainController;
    _selectedCategoryStr = _ctrlr.categories.first.title;
  }

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _selectedCategoryStr = widget.expense!.category;
      _selectedDate = widget.expense!.datetime;
      titleInputCtrl = TextEditingController(text: widget.expense!.title);
      amountInputCtrl = TextEditingController(
        text: (widget.expense!.amount / 100).toStringAsFixed(2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryFontSize = widget.labelFontSize - 2;
    final entryCellHeight = widget.labelFontSize + 10;
    const double entrySpacing = 17;

    //// Setup /////////////////////////////////////////////////////////////////////////////////////

    amountInputCtrl.addListener(() {
      amountInputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: amountInputCtrl.text.length,
      ));
    });

    //// Helpers ///////////////////////////////////////////////////////////////////////////////////

    bool notValidInputs() {
      final emptyTitle = titleInputCtrl.text.isEmpty;
      final emptyAmount = amountInputCtrl.text == "0.00";

      if (emptyTitle || emptyAmount) {
        setState(() {
          emptyTitle ? _titleFilled = false : _titleFilled = true;
          emptyAmount ? _amountFilled = false : _amountFilled = true;
        });
        return true;
      }
      return false;
    }

    void addExpenseCallback() async {
      if (notValidInputs()) return;

      Navigator.pop(context);
      await _ctrlr.addExpense(
        Expense(
          datetime: _selectedDate,
          amount: MainController.formatAmountToInsert(
              double.parse(amountInputCtrl.text)),
          title: titleInputCtrl.text,
          category: _selectedCategoryStr,
        ),
      );

      widget.onNewExpense!();
    }

    void editExpenseCallback() async {
      if (notValidInputs()) return;

      Navigator.pop(context);
      await _ctrlr.editExpense(
        oldExpense: widget.expense!,
        newExpense: Expense(
          title: titleInputCtrl.text,
          amount: MainController.formatAmountToInsert(
            double.parse(amountInputCtrl.text),
          ),
          category: _selectedCategoryStr,
          datetime: _selectedDate,
        ),
      );

      widget.onEditExpense!();
    }

    Widget pageTitle = Align(
      alignment: FractionalOffset.topLeft,
      child: Text(
        widget.label,
        maxLines: 2,
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    Widget titleEntry = Row(
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
    );

    Widget categorySelect = Row(
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
              value: _selectedCategoryStr,
              underline: const SizedBox(),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategoryStr = value!;
                });
              },
              items: _ctrlr.categories.map<DropdownMenuItem<String>>(
                (Category value) {
                  return DropdownMenuItem<String>(
                    value: value.title,
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Text(
                        value.title,
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
    );

    Widget dateSelect = Row(
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
                  initialDate: _selectedDate,
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
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(fontSize: entryFontSize),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    Widget amountEntry = Row(
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
              keyboardType: const TextInputType.numberWithOptions(),
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
    );

    Widget okButton = FloatingActionButton(
      heroTag: "add-button",
      onPressed:
          widget.expense == null ? addExpenseCallback : editExpenseCallback,
      shape: const CircleBorder(),
      child: const Icon(Icons.check),
    );

    Widget closeButton = FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
      },
      shape: const CircleBorder(),
      backgroundColor: Colors.redAccent,
      child: const Icon(Icons.close),
    );

    //// Widget ////////////////////////////////////////////////////////////////////////////////////

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
                bottom: 90,
                top: 70,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //// Add Expense //////////////////////////////
                  pageTitle,

                  Column(
                    children: [
                      //
                      titleEntry,

                      const SizedBox(
                        width: double.infinity,
                        height: entrySpacing,
                      ),

                      categorySelect,

                      const SizedBox(
                        width: double.infinity,
                        height: entrySpacing,
                      ),

                      dateSelect,

                      const SizedBox(
                        width: double.infinity,
                        height: entrySpacing == 0 ? 0 : entrySpacing - 10,
                      ),

                      amountEntry,
                    ],
                  ),

                  Column(
                    children: [
                      okButton,
                      const SizedBox(width: double.infinity, height: 30),
                      closeButton,
                    ],
                  ),
                ],
              ),
            ),
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
    if (newValue.text == "") {
      return TextEditingValue(
        text: "0.00",
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
    }
    return TextEditingValue(
      text: (double.parse(newValue.text) / 100).toStringAsFixed(2),
      selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
    );
  }
}
