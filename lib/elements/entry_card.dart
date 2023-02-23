import 'package:flutter/material.dart';
import 'package:my_expense/data/controller.dart';
import 'package:my_expense/theme.dart';

extension StringExtension on String {
  String fixEllipsis() {
    return replaceAll('', '\u200B');
  }
}

Widget createEntryCard(
  BuildContext context, {
  required Expense expense,
  required Function(Expense) onLongPress,
}) {
  final elmtThemes = Theme.of(context).extension<ElementThemes>();

  Widget createCard() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                    child: expense.category.icon,
                  ),

                  //// Title ///////////////////////////////////////////////////////////////////
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.0, horizontal: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expense.title,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 17,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Text(
                            expense.category.title,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 10,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //// Amount //////////////////////////////////////////////////////////////////////////
            Text(
              "\$${(expense.amount / 100).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
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
