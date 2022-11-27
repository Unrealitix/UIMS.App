import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';

import 'tabs/log.dart';
import 'tabs/scan.dart';

class TabManager extends StatefulWidget {
  const TabManager({super.key});

  @override
  State<TabManager> createState() => _TabManagerState();
}

class _TabManagerState extends State<TabManager> {
  // This needs to be captured here in a stateful widget
  late PlatformTabController tabController;
  late List<Tabby> tabs;

  @override
  void initState() {
    super.initState();

    // If you want further control of the tabs have one of these
    tabController = PlatformTabController(
      initialIndex: 0,
    );

    tabs = [
      const Scan(),
      const Log(),
    ];

    //TODO: Implement this
    // tabController.addListener(() {
    //   for (int i = 0; i < tabs.length; i++) {
    //     if (i == tabController.index(context)) {
    //       tabs[i].onShow.call();
    //     } else {
    //       tabs[i].onHide.call();
    //     }
    //   }
    // });
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
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: tabs,
      ),
      items: const [
        BottomNavigationBarItem(
          label: "Scan",
          icon: Icon(Icons.camera_alt),
        ),
        BottomNavigationBarItem(
          label: "Log",
          icon: Icon(Icons.list),
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
