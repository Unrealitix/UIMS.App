import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

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
