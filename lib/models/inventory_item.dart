import 'dart:convert';
import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../rest_client.dart';
import '../utils.dart';
import 'inventory_group.dart';

class Item {
  String name;
  String sku;
  int quantity;
  Group? group;
  String? barcode;
  String? description;
  String? supplier;

  Item({
    required this.name,
    required this.sku,
    required this.quantity,
    this.group,
    this.barcode,
    this.description,
    this.supplier,
  });

  void changeQuantityTo(int newQuantity) {
    quantity = newQuantity;
    changeItemOnServer(this);
  }

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

  static Future<Item?> dialogEditItem(context, item) async {
    //TODO: Finish this and combine with dialogNewItem
    // Currently it doesn't update to the api correctly
    await showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Edit item"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: item.name,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (String s) {
                  item.name = s;
                },
              ),
              TextFormField(
                initialValue: item.sku,
                decoration: const InputDecoration(
                  labelText: "SKU",
                ),
                onChanged: (String s) {
                  item.sku = s;
                },
              ),
              TextFormField(
                initialValue: item.barcode,
                decoration: const InputDecoration(
                  labelText: "Barcode",
                ),
                onChanged: (String s) {
                  item.barcode = s;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: PlatformTextButton(
                  child: const Text("Delete Item"),
                  onPressed: () async {
                    Item.deleteItemFromServer(item);
                  },
                ),
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
              child: const Text("Save"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return item;
  }

  //rest: get
  static Future<List<Item>> getItemsFromServer() async {
    String resp = await RestClient().get("items").onError(
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

    List<dynamic> json = jsonDecode(resp);

    return json.map((e) => Item.fromJson(e)).toList();
  }

  //rest: post
  static void sendNewItemToServer(Item item) async {
    String resp = await RestClient().post("items", jsonEncode(item)).onError(
      (HttpException error, StackTrace stackTrace) {
        final SnackBar snackBar =
            SnackBar(content: Text("Network error: ${error.message}"));
        snackbarKey.currentState?.showSnackBar(snackBar);
        //TODO: 409 is a conflict, not a network error
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
    const SnackBar snackBar =
        SnackBar(content: Text("Successfully added item"));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  //rest: put
  static void changeItemOnServer(Item item) async {
    String resp = await RestClient()
        .put("items/${item.sku}", jsonEncode(item))
        .onError((error, StackTrace stackTrace) {
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
    const SnackBar snackBar =
        SnackBar(content: Text("Successfully changed item"));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  //rest: delete
  static void deleteItemFromServer(Item item) async {
    String resp = await RestClient()
        .delete("items/${item.sku}")
        .onError((error, StackTrace stackTrace) {
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
    const SnackBar snackBar =
        SnackBar(content: Text("Successfully deleted item"));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }
}
