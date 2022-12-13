import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'tabs/inventory.dart';
import 'tabs/scan.dart';

class TabbedView extends StatefulWidget {
  const TabbedView({super.key});

  @override
  State<TabbedView> createState() => _TabbedViewState();
}

class _TabbedViewState extends State<TabbedView> {
  final List<Widget> tabs = [
    const Scan(),
    const Inventory(),
    const Center(
      //TODO: Make the More tab
      child: Text("More"),
    ),
  ];

  int selectedIndex = 1; //Start on the inventory tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 56),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Image(
                fit: BoxFit.fitHeight,
                image: ResizeImage(
                  AssetImage("assets/images/vanir_icon_2_fg6.png"),
                  height: 56,
                ),
              ),
              Text(AppLocalizations.of(context)!.appName),
            ],
          ),
        ),
      ),
      body: tabs[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.tabScanLabel,
            tooltip: AppLocalizations.of(context)!.tabScanTooltip,
            icon: const Icon(Icons.document_scanner),
            activeIcon: const Icon(Icons.document_scanner_rounded),
          ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.tabInventoryLabel,
            tooltip: AppLocalizations.of(context)!.tabInventoryTooltip,
            icon: const Icon(Icons.list_alt),
            activeIcon: const Icon(Icons.list_alt_rounded),
          ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.tabMoreLabel,
            tooltip: AppLocalizations.of(context)!.tabMoreTooltip,
            icon: const Icon(Icons.more_horiz),
            activeIcon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}
