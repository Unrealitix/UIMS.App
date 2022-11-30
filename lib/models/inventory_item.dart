import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:unrealitix_ims/utils.dart';

class Item {
  String name;
  int quantity;
  String sku;
  String? barcode;
  String? description;

  Item({
    required this.name,
    required this.quantity,
    required this.sku,
    this.barcode,
    this.description,
  });

  static Future<Item?> dialogNewItem(BuildContext context, {
    String? barcode,
  }) async {
    String? name;
    String? sku;
    int quantity = 1;

    bool itemAccepted = false;

    await showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Add item"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (String s) {
                  name = s;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "SKU",
                ),
                onChanged: (String s) {
                  sku = s;
                },
              ),
              TextFormField(
                initialValue: barcode,
                decoration: const InputDecoration(
                  labelText: "Barcode",
                ),
                onChanged: (String s) {
                  barcode = s;
                },
              ),
            ],
          ),
          actions: [
            PlatformDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text("Add"),
              onPressed: () {
                itemAccepted = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (!itemAccepted) return null;

    if (name == null || sku == null) {
      simpleSnackbar(context, "Item wasn't complete", icon: Icons.warning);
      return null;
    }
    return Item(name: name!, quantity: quantity, sku: sku!, barcode: barcode);
  }
}
