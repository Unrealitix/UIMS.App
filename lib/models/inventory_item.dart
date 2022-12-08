import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../rest_client.dart';
import '../utils.dart';
import 'inventory_group.dart';

class Item {
  String name;
  String sku;
  int quantity;
  Group? group;
  String? barcode;
  String? supplier;
  String? description;

  bool toDelete = false;

  Item({
    required this.name,
    required this.sku,
    required this.quantity,
    this.group,
    this.barcode,
    this.supplier,
    this.description,
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
        "supplier": supplier,
        "description": description,
      };

  static Item fromJson(Map<String, dynamic> json) {
    return Item(
      sku: json["sku"] as String,
      quantity: json["quantity"] as int,
      name: json["name"] as String,
      barcode: json["barcode"] as String?,
      supplier: json["supplier"] as String?,
      description: json["description"] as String?,
    );
  }

  static List<Item> globalItems = [];

  static Future<Item?> getItemByBarcodeDialog(
      BuildContext context, String barcode) async {
    //TODO: FINISH THIS
    List<Item> items =
        globalItems.where((item) => item.barcode == barcode).toList();
    if (items.isEmpty) {
      return null;
    } else if (items.length == 1) {
      return items.first;
    } else {
      Item? ret;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(AppLocalizations.of(context)!.duplicateBarcodeDialogTitle),
            content: RawScrollbar(
              thickness: 2,
              interactive: false,
              thumbVisibility: true,
              thumbColor: Colors.grey.withOpacity(0.5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (Item i in items)
                      RadioListTile<Item>(
                        title: Text(i.name),
                        subtitle: Text(i.sku),
                        value: i,
                        groupValue: null,
                        onChanged: (Item? value) {
                          Navigator.of(context).pop();
                          ret = i;
                        },
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.dialogCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return ret;
    }
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
    final nameVerificationKey = GlobalKey<FormFieldState>();
    final skuVerificationKey = GlobalKey<FormFieldState>();
    final quantityVerificationKey = GlobalKey<FormFieldState>();
    bool acceptReturn = false;

    bool isNew = item.sku.isEmpty;
    String title = isNew
        ? AppLocalizations.of(context)!.itemNewDialogTitle
        : AppLocalizations.of(context)!.itemEditDialogTitle;
    String buttonText = isNew
        ? AppLocalizations.of(context)!.dialogCreate
        : AppLocalizations.of(context)!.dialogSave;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: RawScrollbar(
            thickness: 2,
            interactive: false,
            thumbVisibility: true,
            thumbColor: Colors.grey.withOpacity(0.5),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  //To align the delete button to the right:
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Focus(
                      canRequestFocus: false,
                      child: TextFormField(
                        key: nameVerificationKey,
                        autofocus: isNew,
                        initialValue: item.name,
                        decoration: InputDecoration(
                          labelText:
                              "${AppLocalizations.of(context)!.itemPropertyName} ${AppLocalizations.of(context)!.itemPropertyRequired}",
                        ),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        onSaved: (String? s) => item.name = (s ?? "").trim(),
                        validator: (String? s) {
                          if (s == null || s.isEmpty) {
                            return AppLocalizations.of(context)!
                                .itemNewDialogNameEmptyWarning;
                          }
                          return null;
                        },
                      ),
                      onFocusChange: (bool hasFocus) {
                        if (!hasFocus) {
                          nameVerificationKey.currentState?.validate();
                        }
                      },
                    ),
                    Focus(
                      canRequestFocus: false,
                      child: TextFormField(
                        key: skuVerificationKey,
                        initialValue: item.sku,
                        decoration: InputDecoration(
                          labelText:
                              "${AppLocalizations.of(context)!.itemPropertySKU} ${AppLocalizations.of(context)!.itemPropertyRequired}",
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (String? s) => item.sku = (s ?? "").trim(),
                        validator: (String? s) {
                          if (s == null || s.isEmpty) {
                            return AppLocalizations.of(context)!
                                .itemNewDialogSKUEmptyWarning;
                          }
                          return null;
                        },
                      ),
                      onFocusChange: (bool hasFocus) {
                        if (!hasFocus) {
                          skuVerificationKey.currentState?.validate();
                        }
                      },
                    ),
                    Focus(
                      canRequestFocus: false,
                      child: TextFormField(
                        key: quantityVerificationKey,
                        initialValue: item.quantity.toString(),
                        decoration: InputDecoration(
                          labelText:
                              "${AppLocalizations.of(context)!.itemPropertyQuantity} ${AppLocalizations.of(context)!.itemPropertyRequired}",
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (String? s) =>
                            item.quantity = int.tryParse(s!) ?? 1,
                        validator: (String? s) {
                          if (s == null || s.isEmpty) {
                            return AppLocalizations.of(context)!
                                .itemNewDialogQuantityEmptyWarning;
                          }
                          if (int.tryParse(s) == null) {
                            return AppLocalizations.of(context)!
                                .itemNewDialogQuantityInvalidWarning;
                          }
                          return null;
                        },
                      ),
                      onFocusChange: (bool hasFocus) {
                        if (!hasFocus) {
                          quantityVerificationKey.currentState?.validate();
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: item.barcode,
                      decoration: InputDecoration(
                        labelText:
                            "${AppLocalizations.of(context)!.itemPropertyBarcode} ${AppLocalizations.of(context)!.itemPropertyOptional}",
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (String? s) => item.barcode = s?.trim(),
                    ),
                    TextFormField(
                      initialValue: item.supplier,
                      decoration: InputDecoration(
                        labelText:
                            "${AppLocalizations.of(context)!.itemPropertySupplier} ${AppLocalizations.of(context)!.itemPropertyOptional}",
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onSaved: (String? s) => item.supplier = s?.trim(),
                    ),
                    TextFormField(
                      initialValue: item.description,
                      decoration: InputDecoration(
                        labelText:
                            "${AppLocalizations.of(context)!.itemPropertyDescription} ${AppLocalizations.of(context)!.itemPropertyOptional}",
                      ),
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
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
                      TextButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning),
                            Text(
                                " ${AppLocalizations.of(context)!.itemEditDialogDeleteItemButton}"),
                          ],
                        ),
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
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.dialogCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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
  static Future<void> getItemsFromServer() async {
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

    globalItems = json.map((e) => Item.fromJson(e)).toList();
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
    debugPrint("resp: $resp");
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
    debugPrint("resp: $resp");
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
    debugPrint("resp: $resp");
    showSnackbar("Successfully deleted item");
  }
}
