import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';

import 'tabbed_view.dart';
import 'utils.dart';

//TODO: Remove this, it's only for debugging
// When changing this value, you have to stop and completely rebuild the app
const PlatformStyle _debugPlatformStyle = PlatformStyle.Material;

const Color mainColour = Color(0xFFFF8E00);
const Color accentColour = Color(0xFFFFB04C);
const Color blueColour = Color(0xFF58A6D8);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    const bottomNavigationBarThemeData = BottomNavigationBarThemeData(
      selectedItemColor: mainColour,
      unselectedItemColor: accentColour,
    );

    final materialLightTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: mainColour,
      ),
      bottomNavigationBarTheme: bottomNavigationBarThemeData,
      colorScheme: const ColorScheme.light().copyWith(
        primary: mainColour,
        secondary: accentColour,
        //FAB Icon Colour:
        // onSecondary: Colors.red,
      ),
    );

    final materialDarkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: mainColour,
      ),
      bottomNavigationBarTheme: bottomNavigationBarThemeData,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: mainColour,
        secondary: accentColour,
      ),
      dividerColor: Colors.white.withOpacity(0.2),
    );

    const cupertinoTheme = CupertinoThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: mainColour,
        darkColor: mainColour,
      ),
    );

    return PlatformProvider(
      settings: PlatformSettingsData(
        //TODO: Remove this, it's only for debugging
        platformStyle: const PlatformStyleData(android: _debugPlatformStyle),
      ),
      builder: (context) => PlatformSnackApp(
        scaffoldMessengerKey: snackbarKey,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        title: "Vanir IMS",
        materialTheme: materialLightTheme,
        materialDarkTheme: materialDarkTheme,
        materialThemeMode: ThemeMode.system,
        cupertinoTheme: cupertinoTheme,
        home: const TabbedView(),
      ),
    );
  }
}
