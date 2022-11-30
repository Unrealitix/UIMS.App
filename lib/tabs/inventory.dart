import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import '../tabbed_view.dart';
import '../models/inventory_item.dart';

class Inventory extends Tabby {
  Inventory({super.key, super.onShow, super.onHide});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    print("Inventory::initState");

    widget.onShow = () {
      print("Inventory::onShow");
    };
    widget.onHide = () {
      print("Inventory::onHide");
    };

    items = [
      Item(name: "Bread", quantity: 1, sku: "no.1"),
      Item(name: "Milk", quantity: 1, sku: "no.2"),
      Item(name: "Eggs", quantity: 1, sku: "no.3"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print("Inventory::build");
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshList,
          child: ListView.separated(
            itemBuilder: (context, index) {
              double iconSize = 20;
              return ListTile(
                title: Text(items[index].name, style: darkText(context)),
                subtitle:
                    Text("SKU: ${items[index].sku}", style: darkText(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: iconSize,
                      color: isDark(context) ? Colors.white : Colors.black,
                      onPressed: () {
                        setState(() {
                          items[index].quantity =
                              max(0, items[index].quantity - 1);
                        });
                      },
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: (isDark(context) ? Colors.white : Colors.black)
                              .withOpacity(0.3),
                        ),
                      ),
                      onPressed: () async {
                        String? s = await _showQuickQuantityDialog(
                            context, items[index].quantity.toString());
                        print(s);
                        if (s == null) return;
                        int? i = int.tryParse(s);
                        if (i == null || i < 0) {
                          simpleSnackbar(context, "Invalid quantity",
                              icon: Icons.error);
                          return;
                        }
                        setState(() {
                          items[index].quantity = i;
                        });
                      },
                      child: PlatformText(
                        items[index].quantity.toString(),
                        style: darkText(context).copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: iconSize,
                      color: isDark(context) ? Colors.white : Colors.black,
                      onPressed: () {
                        setState(() {
                          items[index].quantity = items[index].quantity + 1;
                        });
                      },
                    ),
                  ],
                ),
                onTap: () {
                  print("Tapped");
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                indent: 8,
                endIndent: 8,
                height: 0,
                thickness: 1,
                //Cupertino has a bug where it doesn't show the divider in dark mode
              );
            },
            itemCount: items.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              tooltip: "Add item",
              onPressed: () async {
                Item? ni = await _showAddItemDialog(context);
                if (ni == null) return;
                setState(() {
                  items.add(ni);
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Item?> _showAddItemDialog(BuildContext ctx) async {
    String? name;
    String? sku;
    int quantity = 1;

    await showPlatformDialog(
      context: ctx,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (String s) {
                  name = s;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "SKU",
                ),
                onChanged: (String s) {
                  sku = s;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (name == null || sku == null) return null;
    return Item(name: name!, quantity: quantity, sku: sku!);
  }

  Future<String?> _showQuickQuantityDialog(BuildContext ctx, String ini) async {
    String? result;

    TextEditingController controller = TextEditingController(
      text: ini,
    );
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: ini.length,
    );

    await showPlatformDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Quantity"),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Quantity",
              labelText: "Enter the new quantity",
              counterText: "Previous quantity: $initial", //TODO: Maybe..
            ),
            style: darkText(context),
            onEditingComplete: () {
              Navigator.of(context).pop();
              result = controller.text;
            },
          ),
          actions: [
            PlatformDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                result = null;
              },
            ),
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                result = controller.text;
              },
            ),
          ],
        );
      },
    );

    if (result == null) return null;
    if (result!.isEmpty) return "0";
    return result;
  }
}
