import 'package:flutter/widgets.dart';

import '../main.dart';

class Log extends StatefulWidget {
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
