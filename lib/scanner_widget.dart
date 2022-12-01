import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'models/inventory_item.dart';
import 'rest_client.dart';
import 'utils.dart';

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
      //TODO: This is being worked on and improved in the library.
      // Waiting for the library to be updated.
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

              _dialogNewScannedItem(context, text);
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

  _dialogNewScannedItem(BuildContext context, String text) async {
    lastScannedCode = text;
    isPopupCurrentlyOpen = true;

    Item? item = await Item.dialogNewItem(context, barcode: text);

    isPopupCurrentlyOpen = false;
    _lastScannedCodeDelayedReset();

    if (item == null) {
      print("item was null");
      return;
    }
    if (item.barcode == null) {
      print("item barcode was null");
      return;
    }

    //TODO: Link to out own API, and send whole item, instead of only barcode
    _restThings(item);
  }

  void _lastScannedCodeDelayedReset() async {
    await Future.delayed(const Duration(seconds: 2), () {
      lastScannedCode = "";
    });
  }

  void _restThings(Item item) async {
    String resp = await RestClient().post("items", jsonEncode(item)).onError(
      (HttpException error, StackTrace stackTrace) {
        final SnackBar snackBar =
            SnackBar(content: Text("Network error: ${error.message}"));
        snackbarKey.currentState?.showSnackBar(snackBar);
        return "network error";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        const SnackBar snackBar =
            SnackBar(content: Text("Not connected to the internet"));
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
      return "not connected to the internet";
    });
    if (resp.isEmpty) {
      const SnackBar snackBar = SnackBar(content: Text("Server responded bad"));
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
    print("resp: $resp");
  }
}
