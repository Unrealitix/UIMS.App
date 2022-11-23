import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        home: const PlatformPage(),
      ),
    );
  }
}

class PlatformPage extends StatelessWidget {
  const PlatformPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Unrealitix Inventory Management System"),
        trailingActions: [
          PlatformIconButton(
            materialIcon: const Icon(Icons.apple),
            cupertinoIcon: const Icon(CupertinoIcons.rocket_fill),
            onPressed: () {
              PlatformProviderState? p = PlatformProvider.of(context);
              if (p == null) return;
              isMaterial(context)
                  ? p.changeToCupertinoPlatform()
                  : p.changeToMaterialPlatform();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              "Center",
              style: darkText(context),
            ),
          ),
        ],
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
