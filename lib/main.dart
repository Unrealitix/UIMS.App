import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:unrealitix_ims/tabs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    final materialLightTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
      ),
      colorScheme: const ColorScheme.light().copyWith(
        primary: Colors.blue,
        secondary: Colors.lightBlueAccent,
      ),
    );

    final materialDarkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.blue,
        secondary: Colors.lightBlueAccent,
      ),
    );

    const cupertinoTheme = CupertinoThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.systemBlue,
        darkColor: CupertinoColors.systemRed,
      ),
    );

    return PlatformProvider(
      builder: (context) => PlatformApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        title: "Unrealitix IMS",
        material: (context, platform) => MaterialAppData(
          theme: materialLightTheme,
          darkTheme: materialDarkTheme,
          themeMode: ThemeMode.system,
        ),
        cupertino: (context, platform) => CupertinoAppData(
          theme: cupertinoTheme,
        ),
        home: const TabManager(),
      ),
    );
  }
}

TextStyle darkText(BuildContext context) {
  return TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black);
}
