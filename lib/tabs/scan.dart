import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:icon_decoration/icon_decoration.dart';
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
      debugPrint("ScanTab::onPermissionSet: $hasPermissions");
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
    debugPrint("ScanTab::initState");
    player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    debugPrint("ScanTab::dispose");
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

  IconData get _scannerModeIcon {
    switch (scannerMode) {
      case _ScannerMode.newItem:
        return Icons.edit;
      case _ScannerMode.addition:
        return Icons.add;
      case _ScannerMode.subtraction:
        return Icons.remove;
    }
  }

  AssetImage get _scannerModeImage {
    switch (scannerMode) {
      case _ScannerMode.newItem:
        return const AssetImage("assets/crosshairs/new_edit.png");
      case _ScannerMode.addition:
        return const AssetImage("assets/crosshairs/plus.png");
      case _ScannerMode.subtraction:
        return const AssetImage("assets/crosshairs/minus.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("ScanTab::build");
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
            debugPrint("scanned text: $text");

            lastScannedCode = text;
            isPopupCurrentlyOpen = true;

            switch (scannerMode) {
              case _ScannerMode.newItem:
                //CHeck if item isn't already in inventory
                var items =
                    Item.globalItems.where((item) => item.barcode == text);
                if (items.isEmpty) {
                  //if it's not in the inv already, add it
                  player.play(newBeep);
                  await _dialogNewScannedItem(context, text);
                } else {
                  //otherwise check if the barcode
                  player.play(existingBeep);
                  Item? i = await Item.getItemByBarcodeDialog(context, text);
                  if (i != null) {
                    await Item.dialogEditItem(context, i);
                  }
                }

                break;
              case _ScannerMode.addition:
                Item? i = await Item.getItemByBarcodeDialog(context, text);
                if (i == null) {
                  showSnackbar("Item not found");
                  break;
                }
                player.play(existingBeep);
                i.changeQuantityTo(i.quantity + 1);
                break;
              case _ScannerMode.subtraction:
                Item? i = await Item.getItemByBarcodeDialog(context, text);
                if (i == null) {
                  showSnackbar("Item not found");
                  break;
                }
                player.play(existingBeep);
                i.changeQuantityTo(max(i.quantity - 1, 0));
                break;
            }

            isPopupCurrentlyOpen = false;
            _lastScannedCodeDelayedReset();
          },
          onStart: (MobileScannerArguments? arguments) {
            debugPrint("CameraComponent::onStart");
            if (arguments == null) return;
            debugPrint("hasTorch: ${arguments.hasTorch}");
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
              spacing: 8,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.edit_note),
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
                  child: Image.asset(
                    "assets/icons/playlist_subtract4.png",
                    width: 22,
                    height: 22,
                    filterQuality: FilterQuality.low,
                    isAntiAlias: true,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  label: AppLocalizations.of(context)!.scanModeLabelSubtraction,
                  onTap: () => setState(() {
                    scannerMode = _ScannerMode.subtraction;
                  }),
                ),
              ],
              activeIcon: Icons.close,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.party_mode),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    // alignment: Alignment.bottomLeft,
                    child: DecoratedIcon(
                      icon: Icon(_scannerModeIcon, size: 20),
                      decoration: IconDecoration(
                        border: IconBorder(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: Image(
              image: _scannerModeImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  _dialogNewScannedItem(BuildContext context, String text) async {
    Item? item = await Item.dialogNewItem(context, barcode: text);

    if (item == null || item.name.isEmpty || item.sku.isEmpty) {
      debugPrint("item was null");
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
