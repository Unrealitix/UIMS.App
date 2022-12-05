import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../main.dart';
import '../models/inventory_item.dart';
import '../utils.dart';

enum _ScannerMode {
  newItem,
  addition,
  subtraction,
}

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

  _ScannerMode scannerMode = _ScannerMode.newItem;

  final AudioPlayer player = AudioPlayer();
  final Source newBeep = AssetSource("sounds/Scan_new_item.mp3");
  final Source existingBeep = AssetSource("sounds/Scan_existing_item.mp3");

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    scannerController.dispose();
    player.dispose();

    super.dispose();
  }

  //TODO: These are too long. They shouldn't be longer than 30 characters
  String get _scannerModeString {
    switch (scannerMode) {
      case _ScannerMode.newItem:
        return "Add new item to the inventory";
      case _ScannerMode.addition:
        return "Increase inventory quantity";
      case _ScannerMode.subtraction:
        return "Reduce inventory quantity";
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            fit: BoxFit.cover,
            onDetect: (BarcodeCapture barcodesCapture) async {
              String? text = barcodesCapture.barcodes.first.rawValue;
              if (text == null) return;
              if (isPopupCurrentlyOpen) return;
              if (text == lastScannedCode) return;
              print("scanned text: $text");

              lastScannedCode = text;
              isPopupCurrentlyOpen = true;

              switch (scannerMode) {
                case _ScannerMode.newItem:
                  player.play(newBeep);
                  //TODO: Implement existing item detection:
                  // if(item i is already in inventory) {
                  //   player.play(existingBeep);
                  //   dialogEditItem(i);
                  //   return;
                  // }

                  await _dialogNewScannedItem(context, text);
                  break;
                case _ScannerMode.addition:
                  player.play(existingBeep);
                  showSnackbar("Addition mode not implemented yet");
                  //TODO: Implement addition mode
                  break;
                case _ScannerMode.subtraction:
                  player.play(existingBeep);
                  showSnackbar("Subtraction mode not implemented yet");
                  //TODO: Implement subtraction mode
                  break;
              }

              isPopupCurrentlyOpen = false;
              _lastScannedCodeDelayedReset();
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
          Align(
            alignment: Alignment.bottomLeft,
            child: IconTheme(
              data: const IconThemeData(
                color: Colors.white,
                size: 32,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //TODO: if has multiple cameras
                  IconButton(
                    tooltip: "Switch camera",
                    onPressed: () {
                      scannerController.switchCamera();
                    },
                    icon: const Icon(Icons.cameraswitch),
                  ),
                  if (hasTorch)
                    IconButton(
                      tooltip: "Toggle flashlight",
                      onPressed: () => setState(() {
                        scannerController.toggleTorch();
                      }),
                      icon: Icon(
                        scannerController.torchState.value == TorchState.on
                            ? Icons.flashlight_on_rounded
                            : Icons.flashlight_off_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topCenter,
              child: Chip(
                label: Text(_scannerModeString),
                backgroundColor: isDark(context) ? Color(0xFF303030) : accentColour
                // labelStyle: TextStyle(color: Colors.white),
                //backgroundColor: isDark(context) ? Color.fromRGBO(48, 48, 48, 1) : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SpeedDial(
                tooltip: "Switch camera scanning mode",
                icon: Icons.party_mode, //TODO: Find a better icon for this
                activeIcon: Icons.close,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.playlist_add_check),
                    label: "Add new item to the inventory",
                    onTap: () => setState(() {
                      scannerMode = _ScannerMode.newItem;
                    }),
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.playlist_add),
                    label: "Increase inventory quantity",
                    onTap: () => setState(() {
                      scannerMode = _ScannerMode.addition;
                    }),
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.playlist_remove),
                    label: "Reduce inventory quantity",
                    onTap: () => setState(() {
                      scannerMode = _ScannerMode.subtraction;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  _dialogNewScannedItem(BuildContext context, String text) async {
    Item? item = await Item.dialogNewItem(context, barcode: text);

    if (item == null || item.name.isEmpty || item.sku.isEmpty) {
      print("item was null");
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
