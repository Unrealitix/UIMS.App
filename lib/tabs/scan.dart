import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/inventory_item.dart';
import '../utils.dart';

enum _ScannerMode {
  newItem,
  addition,
  subtraction,
}

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<StatefulWidget> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  MobileScannerController scannerController = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    onPermissionSet: (bool hasPermissions) {
      print("ScanTab::onPermissionSet: $hasPermissions");
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
    print("ScanTab::initState");
    player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    print("ScanTab::dispose");
    scannerController.dispose();
    player.dispose();

    super.dispose();
  }

  String get _scannerModeString {
    switch (scannerMode) {
      case _ScannerMode.newItem:
        return AppLocalizations.of(context)!.scanModeHintNewItem;
      case _ScannerMode.addition:
        return AppLocalizations.of(context)!.scanModeHintAddition;
      case _ScannerMode.subtraction:
        return AppLocalizations.of(context)!.scanModeHintSubtraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("ScanTab::build");
    return Stack(
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
                  tooltip:
                      AppLocalizations.of(context)!.scanSwitchCameraTooltip,
                  onPressed: () {
                    scannerController.switchCamera();
                  },
                  icon: const Icon(Icons.cameraswitch),
                ),
                if (hasTorch)
                  IconButton(
                    tooltip:
                        AppLocalizations.of(context)!.scanToggleFlashTooltip,
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
        Align(
          alignment: Alignment.topCenter,
          child: Chip(
            label: Text(_scannerModeString),
            elevation: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: SpeedDial(
              tooltip: AppLocalizations.of(context)!.scanSwitchModeTooltip,
              //TODO: Find a better icon for this:
              icon: Icons.party_mode,
              activeIcon: Icons.close,
              spacing: 8,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.playlist_add_check),
                  label: AppLocalizations.of(context)!.scanModeLabelNewItem,
                  onTap: () => setState(() {
                    scannerMode = _ScannerMode.newItem;
                  }),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.playlist_add),
                  label: AppLocalizations.of(context)!.scanModeLabelAddition,
                  onTap: () => setState(() {
                    scannerMode = _ScannerMode.addition;
                  }),
                ),
                SpeedDialChild(
                  //TODO: make this a minus icon:
                  child: const Icon(Icons.playlist_remove),
                  label: AppLocalizations.of(context)!.scanModeLabelSubtraction,
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
  }

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
