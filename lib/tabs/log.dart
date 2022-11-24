import 'package:flutter/widgets.dart';

import '../utils.dart';
import '../tab_manager.dart';

class Log extends Tabby {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
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
