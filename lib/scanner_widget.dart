import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unrealitix_ims/rest_client.dart';
import 'package:unrealitix_ims/utils.dart';

class ManagedScannerWidget extends StatefulWidget {
  const ManagedScannerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ManagedScannerWidgetState();
}

class _ManagedScannerWidgetState extends State<ManagedScannerWidget> {
  MobileScannerController scannerController = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    onPermissionSet: (bool hasPermissions) {
      print("CameraComponent::onPermissionSet: $hasPermissions");
    },
  );
  bool hasTorch = false;

  bool isPopupCurrentlyOpen = false;
  String lastScannedCode = "";

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
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
              _showProductDialog(
                context,
                text,
                barcodesCapture.barcodes.first.type,
              );
            },
            onStart: (MobileScannerArguments? arguments) {
              print("CameraComponent::onStart");
              if (arguments == null) return;
              print("hasTorch: ${arguments.hasTorch}");
              setState(() {
                hasTorch = arguments.hasTorch;
              });
            },
          ),
          if (hasTorch)
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
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

  _showProductDialog(BuildContext mainContext, String text, BarcodeType type) {
    isPopupCurrentlyOpen = true;
    showPlatformDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        //prevents back button from closing dialog
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

  void _delayedResetLastScannedCode() async {
    await Future.delayed(const Duration(seconds: 2), () {
      lastScannedCode = "";
    });
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
}
