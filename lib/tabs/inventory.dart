import 'package:flutter/widgets.dart';

import '../utils.dart';
import '../tabbed_view.dart';

class Inventory extends Tabby {
  Inventory({super.key, super.onShow, super.onHide});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late List<String> items;

  @override
  void initState() {
    super.initState();
    print("Inventory::initState");

    widget.onShow = () {
      print("Inventory::onShow");
    };
    widget.onHide = () {
      print("Inventory::onHide");
    };

    items = ["hello", "world"];
  }

  @override
  Widget build(BuildContext context) {
    print("Inventory::build");
    return ListView(
      children: [
        Text(
          "Hello World",
          style: darkText(context),
        ),
      ],
    );
  }
}
