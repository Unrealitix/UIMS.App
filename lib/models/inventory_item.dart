import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import 'inventory_group.dart';

class Item {
  String sku;
  String name;
  Group? group;
  int quantity;
  String? barcode;
  String? description;
  String? supplier;

  Item({
    required this.name,
    required this.quantity,
    required this.sku,
    this.group,
    this.barcode,
    this.description,
    this.supplier,
  });

  Map toJson() => {
    "sku": sku,
    "quantity": quantity,
    "name": name,
    "barcode": barcode,
    "description": description,
    "supplier": supplier,
  };

  static Item fromJson(Map<String, dynamic> json) {

    return Item(
      sku: json["sku"] as String,
      quantity: json["quantity"] as int,
      name: json["name"] as String,
      barcode: json["barcode"] as String?,
      description: json["description"] as String?,
      supplier: json["supplier"] as String?,
    );
  }

  static Future<Item?> dialogNewItem(
    BuildContext context, {
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
                if (name == null || sku == null) {
                  //TODO: make name & sku EditTexts error-red
                  return;
                }
                itemAccepted = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (!itemAccepted) return null;

    return Item(name: name!, quantity: quantity, sku: sku!, barcode: barcode);
  }
}
