import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../tab_manager.dart';

class Scan extends Tabby {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  MobileScannerController scannerController = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool isPopupCurrentlyOpen = false;
  String lastScannedCode = "";

  @override
  void initState() {
    super.initState();
    print("Scan::initState");
  }

  //TODO: Implement this
  // onShow() {
  //   controller.start();
  // }
  //
  // onHide() {
  //   controller.stop();
  // }

  _showExampleDialog(BuildContext context, String text) {
    isPopupCurrentlyOpen = true;
    showPlatformDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: PlatformAlertDialog(
          title: const Text("Barcode"),
          content: Text(text),
          actions: <Widget>[
            PlatformDialogAction(
              child: PlatformText("Cancel"),
              onPressed: () {
                isPopupCurrentlyOpen = false;
                Navigator.pop(context);
              },
            ),
            PlatformDialogAction(
              child: PlatformText("OK"),
              onPressed: () {
                isPopupCurrentlyOpen = false;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Scan::build");
    return Stack(
      children: [
        MobileScanner(
          controller: scannerController,
          fit: BoxFit.cover,
          onDetect: (BarcodeCapture barcodesCapture) {
            String? text = barcodesCapture.barcodes.first.rawValue;
            if (text == null) return;
            if (isPopupCurrentlyOpen) return;
            if (text == lastScannedCode) return;
            print(text);

            lastScannedCode = text;
            _showExampleDialog(context, text);
          },
        ),
        // PlatformElevatedButton(
        //   onPressed: () {
        //     print("button pressed!");
        //   },
        // )
        //TODO: Remove the need for this bandaid button
        Container(
          alignment: Alignment.topCenter,
          child: PlatformElevatedButton(
            child: const Text("Restart Camera"),
            onPressed: () {
              scannerController.stop();
              scannerController.start();
            },
          ),
        ),
      ],
    );
  }
}
