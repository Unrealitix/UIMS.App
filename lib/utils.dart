import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

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

void showSnackbar(String message) {
  snackbarKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
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
