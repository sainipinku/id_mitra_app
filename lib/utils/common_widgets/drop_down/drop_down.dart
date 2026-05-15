import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';



class Dropdown<T> extends StatelessWidget {
  const Dropdown({
    super.key,
    required this.items,
    this.value,
    required this.onChange,
    this.onClear,
    this.hintText = 'Select',
    required this.displayText,
    this.iconEnabledColor,
    this.showClearButton = true,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.centerLeft,
    this.fillColor,
    this.disabled = false,
  });

  final bool showClearButton;
  final List<T> items;
  final String? hintText;
  final T? value;
  final void Function(T? value) onChange;
  final void Function()? onClear;
  final String Function(int index, T value) displayText;
  final Color? iconEnabledColor;
  final TextAlign textAlign;
  final AlignmentGeometry alignment;

  final Color? fillColor;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(

        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: AppTheme.backBtnBgColor,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15), // 🔥 remove arrow padding
      child: DropdownButton<T>(
        underline: const SizedBox(),
        padding: EdgeInsets.zero,

        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
        ),

        iconEnabledColor: iconEnabledColor,

        value: value,

        selectedItemBuilder: (context) => items
            .mapIndexed(
              (index, element) => Align(
            alignment: alignment,
            child: Text(
              displayText(index, element),
              maxLines: 1,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
            .toList(),

        hint: Text(
          hintText ?? 'Select',
          style: MyStyles.regularText(
            size: 12,
            color: AppTheme.black_Color,
          ),
        ),
        style: MyStyles.regularText(
          size: 12,
          color: AppTheme.black_Color,
        ),
        menuMaxHeight: 300,
        dropdownColor: Colors.white,

        items: List.generate(
          items.length,
              (index) => DropdownMenuItem<T>(
            value: items[index],
            child: Text(displayText(index, items[index])),
          ),
        ),

        isExpanded: true,
        onChanged: disabled ? null : onChange,
      ),
    );
  }
}

extension ListExtensions<E> on List<E> {
  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
    for (var index = 0; index < length; index++) {
      yield convert(index, this[index]);
    }
  }
}