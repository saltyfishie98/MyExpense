import 'package:flutter/material.dart';
import 'package:my_expense/data/controller.dart';
import 'package:my_expense/theme.dart';

Widget createEntryCard(
  BuildContext context, {
  required Expense expense,
  required Function(Expense) onLongPress,
}) {
  final elmtThemes = Theme.of(context).extension<ElementThemes>();

  Widget createCard() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              //// Icon ////////////////////////////////////////////////////////////////////
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: elmtThemes?.accent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: elmtThemes?.shadow ?? Colors.black,
                        blurRadius: 5.0,
                        offset: const Offset(1, 2))
                  ],
                ),
              ),

              //// Title ///////////////////////////////////////////////////////////////////
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 7.0, horizontal: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(fontSize: 17),
                    ),
                    Text(
                      expense.category.title,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),

          //// Amount //////////////////////////////////////////////////////////////////////////
          Text(
            "\$${(expense.amount / 100).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  return Material(
    child: Container(
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
      ),
      child: InkWell(
        onLongPress: () => onLongPress(expense),
        onTap: () {},
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(elmtThemes?.cardRadius ?? 5),
        ),
        child: createCard(),
      ),
    ),
  );
}
