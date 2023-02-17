import 'package:flutter/material.dart';

class WidgetRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget activeWidget;
  final Widget dormentWidget;

  const WidgetRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.activeWidget,
    required this.dormentWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (value == groupValue) {
      return InkWell(
        onTap: () => onChanged(value),
        child: activeWidget,
      );
    } else {
      return InkWell(
        onTap: () => onChanged(value),
        child: dormentWidget,
      );
    }
  }
}
