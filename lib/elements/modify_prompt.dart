import 'package:flutter/material.dart';

Widget createModifyPrompt(
  BuildContext context, {
  required List<Widget> options,
  double height = 300,
  EdgeInsetsGeometry padding = const EdgeInsets.only(top: 30),
}) {
  return SizedBox(
    width: double.infinity,
    height: height,
    child: Padding(
      padding: padding,
      child: Column(
        children: options,
      ),
    ),
  );
}

Widget promptButton(String label, {required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(
      child: Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
