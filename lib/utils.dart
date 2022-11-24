import 'package:flutter/material.dart';

TextStyle darkText(BuildContext context) {
  return TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black);
}
