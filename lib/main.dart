import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';

import 'tabbed_view.dart';

//TODO: Remove this, it's only for debugging
// When changing this value, you have to stop and completely rebuild the app
const PlatformStyle _debugPlatformStyle = PlatformStyle.Material;

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
      dividerColor: Colors.white.withOpacity(0.4),
    );

    const cupertinoTheme = CupertinoThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.systemBlue,
        darkColor: CupertinoColors.systemBlue,
      ),
    );

    return PlatformProvider(
      settings: PlatformSettingsData(
        //TODO: Remove this, it's only for debugging
        platformStyle: const PlatformStyleData(android: _debugPlatformStyle),
      ),
      builder: (context) => PlatformSnackApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        title: "Unrealitix IMS",
        materialTheme: materialLightTheme,
        materialDarkTheme: materialDarkTheme,
        materialThemeMode: ThemeMode.system,
        cupertinoTheme: cupertinoTheme,
        home: const TabbedView(),
      ),
    );
  }
}
