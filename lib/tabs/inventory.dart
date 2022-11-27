import 'package:flutter/widgets.dart';

import '../utils.dart';
import '../tabbed_view.dart';

class Inventory extends Tabby {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _LogState();
}

class _LogState extends State<Inventory> {
  late List<String> items;

  @override
  void initState() {
    super.initState();

    items = ["hello", "world"];
  }

  @override
  Widget build(BuildContext context) {
    print("Log::build");
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
