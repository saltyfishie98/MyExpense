import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/data/controller.dart';
import 'package:state_extended/state_extended.dart';
import 'package:tuple/tuple.dart';

typedef EntryRow = Tuple3<String, Widget, double>;

class ExpenseEntryPage extends StatefulWidget {
  const ExpenseEntryPage(
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
  State createState() => _ExpenseEntryPageState();
}

class _ExpenseEntryPageState extends StateX<ExpenseEntryPage> {
  //// States ///////////////////////////////////////////////

  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _titleFilled = true;
  bool _amountFilled = true;
  TextEditingController titleInputCtrl = TextEditingController();
  TextEditingController amountInputCtrl = TextEditingController(text: "0.00");
  late MainController _ctrlr;
  FocusNode entryFocusNode = FocusNode();

  //// Implementations //////////////////////////////////////

  _ExpenseEntryPageState() : super(MainController()) {
    _ctrlr = controller as MainController;
    _selectedCategory = _ctrlr.categories.first;
  }

  @override
  void dispose() {
    super.dispose();
    entryFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.datetime;
      titleInputCtrl = TextEditingController(text: widget.expense!.title);
      amountInputCtrl = TextEditingController(
        text: (widget.expense!.amount / 100).toStringAsFixed(2),
      );
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      FocusScope.of(context).requestFocus(entryFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryFontSize = widget.labelFontSize - 2;
    final entryCellHeight = widget.labelFontSize + 10;
    const double entryHeight = 17;

    //// Setup /////////////////////////////////////////////////////////////////////////////////////

    amountInputCtrl.addListener(() {
      amountInputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: amountInputCtrl.text.length,
      ));
    });

    //// Widget Elements ///////////////////////////////////////////////////////////////////////////

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

    Widget titleEntry = _createEntryElement(
      "Title",
      entryWidget: Container(
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
          focusNode: entryFocusNode,
          onTapOutside: (_) => FocusScope.of(context).requestFocus(FocusNode()),
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(FocusNode()),
        ),
      ),
      trailling: _entryErrorWidget(
        !_titleFilled,
        boxSize: Size(10, entryCellHeight),
      ),
    );

    Widget categorySelect = _createEntryElement(
      "Category",
      entryWidget: Container(
        margin: const EdgeInsets.only(left: 5, right: 0),
        height: entryCellHeight,
        child: DropdownButton<Category>(
          value: _selectedCategory!,
          underline: const SizedBox(),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
          items: _ctrlr.categories.map<DropdownMenuItem<Category>>(
            (Category value) {
              return DropdownMenuItem<Category>(
                value: value,
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Text(
                    value.title,
                    softWrap: false,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: entryFontSize,
                      fontWeight: FontWeight.normal,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );

    Widget dateSelect = _createEntryElement(
      "Date",
      entryWidget: InkWell(
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
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 0),
          height: entryCellHeight,
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
    );

    Widget amountEntry = _createEntryElement(
      "Amount",
      entryWidget: TextField(
        controller: amountInputCtrl,
        keyboardType: const TextInputType.numberWithOptions(),
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 5),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: entryFontSize + 20),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp("[0-9]"),
          ),
          PriceFormatter(),
        ],
      ),
      trailling: _entryErrorWidget(
        !_amountFilled,
        boxSize: Size(10, entryCellHeight),
      ),
    );

    Widget okButton = FloatingActionButton(
      heroTag: "add-button",
      onPressed:
          widget.expense == null ? _addExpenseCallback : _editExpenseCallback,
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

    return Scaffold(
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
                    const SizedBox(width: double.infinity, height: entryHeight),

                    categorySelect,
                    const SizedBox(width: double.infinity, height: entryHeight),

                    dateSelect,
                    const SizedBox(
                      width: double.infinity,
                      height: entryHeight == 0 ? 0 : entryHeight - 10,
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
    );
  }

  Widget _createEntryElement(
    String label, {
    required Widget entryWidget,
    Widget? trailling,
  }) {
    return Row(
      children: [
        SizedBox(
          // adjust label width here if text clips
          width: 100,
          child: Align(
            alignment: FractionalOffset.bottomRight,
            child: Text(
              "$label:",
              maxLines: 1,
              style: TextStyle(fontSize: widget.labelFontSize),
            ),
          ),
        ),
        Expanded(flex: widget.entryFlexValue, child: entryWidget),
        trailling ?? const SizedBox(),
      ],
    );
  }

  bool _notValidInputs() {
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

  void _addExpenseCallback() {
    if (_notValidInputs()) return;

    _ctrlr
        .addExpense(
      Expense(
        datetime: _selectedDate,
        amount: MainController.formatAmountToInsert(
            double.parse(amountInputCtrl.text)),
        title: titleInputCtrl.text,
        category: _selectedCategory!,
      ),
    )
        .then(
      (value) {
        widget.onNewExpense!();
        Navigator.pop(context);
      },
    );
  }

  void _editExpenseCallback() {
    if (_notValidInputs()) return;

    _ctrlr
        .editExpense(
      oldExpense: widget.expense!,
      newExpense: Expense(
        title: titleInputCtrl.text,
        amount: MainController.formatAmountToInsert(
          double.parse(amountInputCtrl.text),
        ),
        category: _selectedCategory!,
        datetime: _selectedDate,
      ),
    )
        .then(
      (value) {
        widget.onEditExpense!();
        Navigator.pop(context);
      },
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
