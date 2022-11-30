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
        color: Color(0xFFF0891F),
      ),
      colorScheme: const ColorScheme.light().copyWith(
        primary: const Color(0xFFF0891F),
        secondary: const Color(0xFFF6AA4F),
      ),
    );

    final materialDarkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Color(0xFFF0891F),
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: const Color(0xFFF0891F),
        secondary: const Color(0xFFF6AA4F),
      ),
      dividerColor: Colors.white.withOpacity(0.2),
    );

    const cupertinoTheme = CupertinoThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF0891F),
        darkColor: Color(0xFFF0891F),
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
