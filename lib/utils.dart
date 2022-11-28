import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

//TODO: Reduce usage of this function with proper theming
bool isDark(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.dark;
}

//TODO: Remove need for this function with proper theming
TextStyle darkText(BuildContext context) {
  return TextStyle(
    color: isDark(context) ? Colors.white : Colors.black,
  );
}

void simpleSnackbar(BuildContext context, String text, {IconData? icon}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        PlatformWidget(
          cupertino: (_, __) => Icon(icon, color: Colors.white),
          material: (_, __) => Icon(
            icon,
            color: isDark(context) ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  ));
}

List<String> splitStringByLength(String str, int length) {
  int strLen = str.length;
  List<String> chunks = [];

  for (int i = 0; i < strLen; i += length) {
    int end = (i + length < strLen) ? i + length : strLen;
    chunks.add(str.substring(i, end));
  }

  return chunks;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
