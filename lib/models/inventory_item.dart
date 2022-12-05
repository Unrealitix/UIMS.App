import 'dart:convert';
import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../main.dart';
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

  bool toDelete = false;

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

  static Item getItemByBarcodeDialog(BuildContext context, String barcode) {
    // List<Item> options = getItemsByBarcodeFromServer(barcode);
    //TODO: Implement this
    throw UnimplementedError();
  }

  ///Returns null if dialog was cancelled
  static Future<Item?> dialogNewItem(
    BuildContext context, {
    String? barcode,
  }) async {
    return await dialogEditItem(
      context,
      Item(
        name: "",
        sku: "",
        quantity: 1,
        barcode: barcode,
      ),
    );
  }

  ///Returns null if dialog was cancelled
  static Future<Item?> dialogEditItem(BuildContext context, Item item) async {
    final formKey = GlobalKey<FormState>();
    final nameKey = GlobalKey<FormFieldState>();
    final skuKey = GlobalKey<FormFieldState>();
    bool acceptReturn = false;

    bool isNew = item.sku.isEmpty;
    String title = isNew ? "New Item" : "Edit Item";
    String buttonText = isNew ? "Create" : "Save";

    await showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        InputDecoration id = InputDecoration(
          labelStyle:
              isDark(context) ? const TextStyle(color: Colors.white60) : null,
          floatingLabelStyle:
              isDark(context) ? const TextStyle(color: mainColour) : null,
        );

        return PlatformAlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                //To align the delete button to the right:
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Focus(
                    child: TextFormField(
                      key: nameKey,
                      autofocus: isNew,
                      initialValue: item.name,
                      style: darkText(context),
                      decoration: id.copyWith(labelText: "Name"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String s) =>
                          FocusScope.of(context).nextFocus(),
                      onSaved: (String? s) => item.name = (s ?? "").trim(),
                      validator: (String? s) {
                        if (s == null || s.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    onFocusChange: (bool hasFocus) {
                      if (!hasFocus) {
                        nameKey.currentState?.validate();
                      }
                    },
                  ),
                  Focus(
                    child: TextFormField(
                      key: skuKey,
                      initialValue: item.sku,
                      style: darkText(context),
                      decoration: id.copyWith(labelText: "SKU"),
                      textInputAction: TextInputAction.next,
                      onSaved: (String? s) => item.sku = (s ?? "").trim(),
                      validator: (String? s) {
                        if (s == null || s.isEmpty) {
                          return "SKU cannot be empty";
                        }
                        return null;
                      },
                    ),
                    onFocusChange: (bool hasFocus) {
                      if (!hasFocus) {
                        skuKey.currentState?.validate();
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: item.barcode,
                    style: darkText(context),
                    decoration: id.copyWith(labelText: "Barcode"),
                    textInputAction: TextInputAction.next,
                    onSaved: (String? s) => item.barcode = s?.trim(),
                  ),
                  TextFormField(
                    initialValue: item.supplier,
                    style: darkText(context),
                    decoration: id.copyWith(labelText: "Supplier"),
                    textInputAction: TextInputAction.next,
                    onSaved: (String? s) => item.supplier = s?.trim(),
                  ),
                  TextFormField(
                    initialValue: item.description,
                    style: darkText(context),
                    decoration: id.copyWith(labelText: "Description"),
                    textInputAction: TextInputAction.newline,
                    onSaved: (String? s) => item.description = s?.trim(),
                    maxLines: null,
                    onChanged: (String s) {
                      //if last two lines are empty, close keyboard
                      if (s.endsWith("\n\n")) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                  if (!isNew)
                    PlatformTextButton(
                      child: const Text("Delete Item"),
                      onPressed: () {
                        Item.deleteItemFromServer(item);
                        item.toDelete = true;
                        acceptReturn = true;
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            PlatformDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              //Save button
              child: Text(buttonText),
              onPressed: () {
                formKey.currentState!.save();
                if (formKey.currentState!.validate()) {
                  acceptReturn = true;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );

    //For when the dialog was cancelled:
    if (!acceptReturn || item.sku.isEmpty || item.name.isEmpty) {
      return null;
    }

    return item;
  }

  ///======================================================================///
  ///                       REST API FUNCTIONS                             ///
  ///======================================================================///

  //rest: get
  static Future<List<Item>> getItemsFromServer() async {
    String resp = await RestClient().get("items").onError(
      (HttpException error, StackTrace stackTrace) {
        showSnackbar("Network error: ${error.message}");
        return "network error";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        showSnackbar("Not connected to the internet");
      }
      return "not connected to the internet";
    });
    if (resp.isEmpty) {
      showSnackbar("Server responded bad");
    }

    List<dynamic> json = jsonDecode(resp);

    return json.map((e) => Item.fromJson(e)).toList();
  }

  static List<Item> getItemsByBarcodeFromServer(String barcode) {
    //TODO: Implement this
    throw UnimplementedError();
  }

  //rest: post
  static void sendNewItemToServer(Item item) async {
    String resp = await RestClient().post("items", jsonEncode(item)).onError(
      (HttpException error, StackTrace stackTrace) {
        showSnackbar("Network error: ${error.message}");
        //TODO: 409 is a conflict, not a network error
        return "network error";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        showSnackbar("Not connected to the internet");
      }
      return "not connected to the internet";
    });
    if (resp.isEmpty) {
      showSnackbar("Server responded bad");
    }
    print("resp: $resp");
    showSnackbar("Successfully added item");
  }

  //rest: put
  static void changeItemOnServer(Item item) async {
    String resp =
        await RestClient().put("items/${item.sku}", jsonEncode(item)).onError(
      (HttpException error, StackTrace stackTrace) {
        showSnackbar("Network error: ${error.message}");
        return "network error";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        showSnackbar("Not connected to the internet");
      }
      return "not connected to the internet";
    });
    //Put requests apparently return empty responses on success,
    // so no need to show an error here
    /*if (resp.isEmpty) {
      // showSnackbar("Server responded bad");
    }*/
    print("resp: $resp");
    showSnackbar("Successfully changed item");
  }

  //rest: delete
  static void deleteItemFromServer(Item item) async {
    String resp = await RestClient().delete("items/${item.sku}").onError(
      (HttpException error, StackTrace stackTrace) {
        showSnackbar("Network error: ${error.message}");
        return "network error";
      },
    ).onError((error, StackTrace stackTrace) {
      if (error.runtimeType.toString() == "_ClientSocketException") {
        showSnackbar("Not connected to the internet");
      }
      return "not connected to the internet";
    });
    //Delete requests apparently return empty responses on success,
    // so no need to show an error here
    /*if (resp.isEmpty) {
      // showSnackbar("Server responded bad");
    }*/
    print("resp: $resp");
    showSnackbar("Successfully deleted item");
  }
}
