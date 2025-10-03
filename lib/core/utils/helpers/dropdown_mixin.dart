import 'package:flutter/material.dart';

mixin DropdownMixin {
  void showCustomDropdown<T>({
    required BuildContext context,
    required List<DropdownItem<T>> items,
    required Function(T) onItemSelected,
    T? selectedValue,
    double? width,
    double? maxHeight,
    BorderRadius? borderRadius,
    double? elevation,
  }) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + (width ?? renderBox.size.width),
        position.dy + renderBox.size.height + (maxHeight ?? 200),
      ),
      items: items
          .map((item) => PopupMenuItem<T>(
                value: item.value,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: selectedValue == item.value
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selectedValue == item.value
                              ? (item.selectedColor ?? Colors.orange)
                              : (item.textColor ?? Colors.black),
                        ),
                      ),
                    ),
                    if (selectedValue == item.value)
                      Icon(
                        Icons.check,
                        color: item.selectedColor ?? Colors.orange,
                        size: 20,
                      ),
                  ],
                ),
              ))
          .toList(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
      elevation: elevation ?? 8,
    ).then((selectedItem) {
      if (selectedItem != null) {
        onItemSelected(selectedItem);
      }
    });
  }
}

/// Data class for dropdown items
class DropdownItem<T> {
  final T value;
  final String label;
  final Color? textColor;
  final Color? selectedColor;
  final IconData? icon;

  const DropdownItem({
    required this.value,
    required this.label,
    this.textColor,
    this.selectedColor,
    this.icon,
  });
}
