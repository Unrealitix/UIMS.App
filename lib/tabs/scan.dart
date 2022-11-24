import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../rest_client.dart';
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

  void _delayedResetLastScannedCode() async {
    await Future.delayed(const Duration(seconds: 1), () {
      lastScannedCode = "";
    });
  }

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
                _delayedResetLastScannedCode();
              },
            ),
            PlatformDialogAction(
              child: PlatformText("OK"),
              onPressed: () async {
                isPopupCurrentlyOpen = false;
                Navigator.pop(context);
                _delayedResetLastScannedCode();

                //TODO: Link to out own API
                var resp = await RestClient().post("post", {"barcode": text});
                print(resp);
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
        //TODO: Remove the need for this band-aid button, using tab show/hide events
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
        // Container(
        //   alignment: Alignment.center,
        //   child: PlatformElevatedButton(
        //     child: const Text("REST"),
        //     onPressed: () async {
        //       // RestClient().get("items/2");
        //
        //       // RestClient().get("cat?json=true");
        //       // var resp = await RestClient().get("api/tags");
        //
        //       // var resp = await RestClient().post("post", "object");
        //       var resp = await RestClient().get("get");
        //       print(resp);
        //     },
        //   ),
        // ),
      ],
    );
  }
}
