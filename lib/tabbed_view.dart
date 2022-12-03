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
      initialIndex: 1, //Note: Never start on the Scan tab.
    );

    Function? onShow;
    Function? onHide;

    tabs = [
      Scan(onShow: onShow, onHide: onHide),
      Inventory(onShow: onShow, onHide: onHide),
    ];
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double selectedIconSize = 48;
    //TODO: Animate between these two icon sizes.
    const double unselectedIconSize = 24;
    return PlatformTabScaffold(
      //This messes up the top of the inventory list, adding too much padding,
      // but its purpose is avoiding stuff being hidden behind the _top_ app bar
      // iosContentPadding: true,
      //This one can stay, to avoid stuff being hidden behind the _bottom_ bar
      iosContentBottomPadding: true,
      tabController: tabController,
      appBarBuilder: (context, index) => PlatformAppBar(
        title: Row(
          children: const [
            Image(
              fit: BoxFit.cover,
              height: 52,
              image: ResizeImage(
                AssetImage("assets/images/vanir_icon_2_fg6.png"),
                width: 52,
              ),
            ),
            Text("Vanir IMS"),
          ],
        ),
      ),
      itemChanged: (int index) {
        print("Tab changed to $index");
        for (int i = 0; i < tabs.length; i++) {
          if (i == tabController.index(context)) {
            tabs[i].onShow?.call();
          } else {
            tabs[i].onHide?.call();
          }
        }
      },
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: tabs,
      ),
      cupertinoTabs: (context, platform) => CupertinoTabBarData(
        height: 72,
      ),
      items: const [
        BottomNavigationBarItem(
          label: "Scan",
          tooltip: "Scan new items into inventory",
          icon: Icon(Icons.document_scanner, size: unselectedIconSize),
          activeIcon:
              Icon(Icons.document_scanner_rounded, size: selectedIconSize),
        ),
        BottomNavigationBarItem(
          label: "Inventory",
          tooltip: "View inventory",
          icon: Icon(Icons.list, size: unselectedIconSize),
          activeIcon: Icon(Icons.list_rounded, size: selectedIconSize),
        ),
      ],
    );
  }
}

class Tabby extends StatefulWidget {
  late Function? onShow;
  late Function? onHide;

  Tabby({super.key, this.onShow, this.onHide});

  @override
  State<StatefulWidget> createState() => TabbyState();
}

class TabbyState extends State<Tabby> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
