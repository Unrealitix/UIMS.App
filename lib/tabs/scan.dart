import 'package:flutter/material.dart';

import '../tabbed_view.dart';
import '../scanner_widget.dart';

class Scan extends Tabby {
  Scan({super.key, super.onShow, super.onHide});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  bool inView = false;

  @override
  void initState() {
    super.initState();
    print("Scan::initState");

    widget.onShow = () {
      print("Scan::onShow");
      setState(() {
        inView = true;
      });
    };
    widget.onHide = () {
      print("Scan::onHide");
      setState(() {
        inView = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    print("Scan::build");
    return Stack(
      children: [
        inView ? const ManagedScannerWidget() : Container(),
      ],
    );
  }
}
