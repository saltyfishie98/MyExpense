import 'package:flutter/material.dart';

class RadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget activeWidget;
  final Widget dormentWidget;

  const RadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.activeWidget,
    required this.dormentWidget,
  });

  void tapCallback(BuildContext context) {
    onChanged(value);
    Feedback.forTap(context);
  }

  @override
  Widget build(BuildContext context) {
    if (value == groupValue) {
      return GestureDetector(
        onTap: () => tapCallback(context),
        child: activeWidget,
      );
    } else {
      return GestureDetector(
        onTap: () => tapCallback(context),
        child: dormentWidget,
      );
    }
  }
}
