import 'dart:io';

import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../utils.dart';
import '../tabbed_view.dart';
import '../rest_client.dart';

class Scan extends Tabby {
  Scan({super.key, super.onShow, super.onHide});

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
    scannerController.stop();

    widget.onShow = () {
      print("Scan::onShow");
      setState(() {
        scannerController.start();
      });
    };
    widget.onHide = () {
      print("Scan::onHide");
      setState(() {
        if (scannerController.torchState.value == TorchState.on) {
          scannerController.toggleTorch();
        }
        scannerController.stop();
      });
    };
  }

  @override
  void dispose() {
    scannerController.dispose();

    super.dispose();
  }

  void _delayedResetLastScannedCode() async {
    await Future.delayed(const Duration(seconds: 1), () {
      lastScannedCode = "";
    });
  }

  _showExampleDialog(BuildContext mainContext, String text, BarcodeType type) {
    isPopupCurrentlyOpen = true;
    showPlatformDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: PlatformAlertDialog(
          title: Text(type.name.toTitleCase()),
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
                _restThings(text, mainContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  _restThings(String text, BuildContext mainContext) async {
    String resp = await RestClient().post("post", text).onError(
      (HttpException error, StackTrace stackTrace) {
        simpleSnackbar(mainContext, "Network error: ${error.message}",
            icon: Icons.error);
        return "";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        simpleSnackbar(mainContext, "Not connected to the internet",
            icon: Icons.error);
      }
      return "";
    });
    if (resp.isEmpty) {
      simpleSnackbar(mainContext, "Server responded bad", icon: Icons.error);
    }
    print("resp: $resp");
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
            print("scanned text: $text");

            lastScannedCode = text;
            _showExampleDialog(
              context,
              text,
              barcodesCapture.barcodes.first.type,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(32.0).add(
            const EdgeInsets.only(bottom: 32),
          ),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  scannerController.toggleTorch();
                });
              },
              child: Icon(
                size: 42,
                scannerController.torchState.value == TorchState.on
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
