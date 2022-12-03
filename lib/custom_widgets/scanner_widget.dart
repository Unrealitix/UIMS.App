import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/inventory_item.dart';

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

  final AudioPlayer player = AudioPlayer();
  final Source newBeep = AssetSource("sounds/Scan_new_item.mp3");
  final Source existingBeep = AssetSource("sounds/Scan_existing_item.mp3");

  @override
  void initState() {
    super.initState();
    player.setPlayerMode(PlayerMode.lowLatency);
    player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    scannerController.dispose();
    player.dispose();

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

              player.play(newBeep);
              //TODO: Implement existing item detection
              // player.play(existingBeep);

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
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    scannerController.toggleTorch();
                  });
                },
                icon: Icon(
                  size: 32,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 20,
                    ),
                  ],
                  scannerController.torchState.value == TorchState.on
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                ),
              ),
            ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Chip(label: Text("Hover over a barcode to scan it")),
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

    Item.sendNewItemToServer(item);
  }

  void _lastScannedCodeDelayedReset() async {
    await Future.delayed(const Duration(seconds: 2), () {
      lastScannedCode = "";
    });
  }
}
