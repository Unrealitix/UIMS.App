import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:unrealitix_ims/tabs/log.dart';
import 'package:unrealitix_ims/tabs/scan.dart';

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
      iosContentPadding: true,
      tabController: tabController,
      appBarBuilder: (context, index) => PlatformAppBar(
        title: const Text("Unrealitix Inventory Management System"),
        // trailingActions: [
        //   PlatformIconButton(
        //     materialIcon: const Icon(Icons.apple),
        //     cupertinoIcon: const Icon(Icons.android),
        //     onPressed: () {
        //       PlatformProviderState? p = PlatformProvider.of(context);
        //       if (p == null) return;
        //       isMaterial(context)
        //           ? p.changeToCupertinoPlatform()
        //           : p.changeToMaterialPlatform();
        //     },
        //   ),
        // ],
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
