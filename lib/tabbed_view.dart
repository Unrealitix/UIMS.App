import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';

import 'tabs/inventory.dart';
import 'tabs/scan.dart';

class TabbedView extends StatefulWidget {
  const TabbedView({super.key});

  @override
  State<TabbedView> createState() => _TabbedViewState();
}

class _TabbedViewState extends State<TabbedView> {
  late PlatformTabController tabController;
  late List<Tabby> tabs;

  @override
  void initState() {
    super.initState();

    tabController = PlatformTabController(
      initialIndex: 1,
    );

    tabs = [
      const Scan(),
      const Inventory(),
    ];
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      tabController: tabController,
      appBarBuilder: (context, index) => PlatformAppBar(
        title: const Text("Unrealitix Inventory Management System"),
      ),
      itemChanged: (int index) {
        print("Tab changed to $index");
        //TODO: Implement this
        // for (int i = 0; i < tabs.length; i++) {
        //   if (i == tabController.index(context)) {
        //     tabs[i].onShow.call();
        //   } else {
        //     tabs[i].onHide.call();
        //   }
        // }
      },
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: tabs,
      ),
      items: const [
        BottomNavigationBarItem(
          label: "Scan",
          tooltip: "Scan new items into inventory",
          icon: Icon(Icons.document_scanner),
          activeIcon: Icon(Icons.document_scanner_rounded),
        ),
        BottomNavigationBarItem(
          label: "Inventory",
          tooltip: "View inventory",
          icon: Icon(Icons.list),
          activeIcon: Icon(Icons.list_rounded),
        ),
      ],
    );
  }
}

class Tabby extends StatefulWidget {
  const Tabby({super.key});

  @override
  State<StatefulWidget> createState() => TabbyState();
}

class TabbyState extends State<Tabby> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
