import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
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
      _refreshList();
    };
    widget.onHide = () {
      print("Inventory::onHide");
    };

    items = [
      // Item(name: "Bread", quantity: 1, sku: "no.1"),
      // Item(name: "Milk", quantity: 1, sku: "no.2"),
      // Item(name: "Eggs", quantity: 1, sku: "no.3"),
    ];

    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Use FutureBuilder to show a loading indicator while waiting for the items to load
    print("Inventory::build");
    return Stack(
      children: [
        RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: _refreshList,
          child: ListView.separated(
            itemBuilder: (context, index) {
              double iconSize = 20;
              Color iconColor = isCupertino(context)
                  ? CupertinoColors.systemBlue
                  : isDark(context)
                      ? Colors.white
                      : Colors.black;
              return ListTile(
                title: Text(items[index].name, style: darkText(context)),
                subtitle:
                    Text("SKU: ${items[index].sku}", style: darkText(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: iconColor),
                      iconSize: iconSize,
                      color: isDark(context) ? Colors.white : Colors.black,
                      onPressed: () {
                        setState(() {
                          items[index].changeQuantityTo(
                              max(0, items[index].quantity - 1));
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
                        int? i = await _showQuickQuantityDialog(
                            context, items[index].quantity.toString());
                        print(i);
                        if (i == null) return; //Dialog cancelled
                        setState(() {
                          items[index].changeQuantityTo(i);
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
                      icon: Icon(Icons.add, color: iconColor),
                      iconSize: iconSize,
                      color: isDark(context) ? Colors.white : Colors.black,
                      onPressed: () {
                        setState(() {
                          items[index]
                              .changeQuantityTo(items[index].quantity + 1);
                        });
                      },
                    ),
                  ],
                ),
                onTap: () {
                  print("Tapped");
                  _showItemDetails(context, items[index]);
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
                Item? ni = await Item.dialogNewItem(context);
                if (ni == null) return;
                setState(() {
                  items.add(ni);
                  Item.sendNewItemToServer(ni);
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
    List<Item> newItems = await Item.getItemsFromServer();
    setState(() {
      items = newItems;
    });
  }

  Future<int?> _showQuickQuantityDialog(
    BuildContext context,
    String initial,
  ) async {
    int? result;

    TextEditingController controller = TextEditingController(
      text: initial,
    );
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: initial.length,
    );
    String? errorMessage;

    void attemptChange(StateSetter setDialogState) {
      if (controller.text.isEmpty) {
        result = 0;
        Navigator.of(context).pop();
        return;
      }
      result = int.tryParse(controller.text);
      setDialogState(() {
        if (result == null || result! < 0) {
          errorMessage = "Invalid quantity";
        } else {
          errorMessage = null;
          Navigator.of(context).pop();
        }
      });
    }

    await showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  errorText: errorMessage,
                ),
                style: darkText(context),
                onEditingComplete: () => attemptChange(setDialogState),
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
                  onPressed: () => attemptChange(setDialogState),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  void _showItemDetails(BuildContext context, Item item) {
    showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: Text(item.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SKU: ${item.sku}"),
              Text("Quantity: ${item.quantity}"),
              if (item.barcode != null && item.barcode!.isNotEmpty)
                Text("Barcode: ${item.barcode}"),
              if (item.description != null && item.description!.isNotEmpty)
                Text("Description: ${item.description}"),
            ],
          ),
          actions: [
            PlatformDialogActionButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit),
                  Text(" Edit"),
                ],
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Item? ni = await Item.dialogEditItem(context, item);
                if (ni == null) return;
                Item.changeItemOnServer(ni);
                setState(() {
                  items[items.indexOf(item)] = ni;
                });
              },
            ),
            PlatformDialogActionButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
