import 'package:flutter/material.dart';

TextStyle darkText(BuildContext context) {
  return TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black);
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
