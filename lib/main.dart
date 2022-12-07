import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'l10n/l10n.dart';
import 'tabbed_view.dart';
import 'utils.dart';

const Color mainColour = Color(0xFFFF8E00);
const Color accentColour = Color(0xFFFFB04C);
const Color blueColour = Color(0xFF58A6D8);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bottomNavigationBarThemeData = BottomNavigationBarThemeData(
      type: BottomNavigationBarType.shifting,
      elevation: 10,
      selectedItemColor: mainColour,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: false,
      showSelectedLabels: true,
      selectedIconTheme: IconThemeData(size: 26),
      unselectedIconTheme: IconThemeData(size: 24),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );

    final materialLightTheme = ThemeData(
      colorScheme: const ColorScheme.light().copyWith(
        primary: mainColour,
        secondary: accentColour,
      ),
      appBarTheme: const AppBarTheme(color: mainColour),
      bottomNavigationBarTheme: bottomNavigationBarThemeData,
      chipTheme: const ChipThemeData(backgroundColor: accentColour),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black, //text colour
          textStyle: const TextStyle(fontSize: 20),
          side: const BorderSide(color: Colors.black26),
        ),
      ),
      cardColor: mainColour, //colour for the Inventory tab top stuff
    );

    final materialDarkTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark().copyWith(
        primary: mainColour,
        secondary: accentColour,
      ),
      appBarTheme: const AppBarTheme(color: mainColour),
      bottomNavigationBarTheme: bottomNavigationBarThemeData,
      chipTheme: const ChipThemeData(backgroundColor: Colors.white10),
      inputDecorationTheme: const InputDecorationTheme(),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white, //text colour
          textStyle: const TextStyle(fontSize: 20),
          side: const BorderSide(color: Colors.white38),
        ),
      ),
      dividerColor: Colors.white.withOpacity(0.2),
    );

    return MaterialApp(
      scaffoldMessengerKey: snackbarKey,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: "Vanir IMS",
      theme: materialLightTheme,
      darkTheme: materialDarkTheme,
      themeMode: ThemeMode.system,
      home: const TabbedView(),
    );
  }
}
