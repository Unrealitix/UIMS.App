import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import '../tabbed_view.dart';

class Inventory extends Tabby {
  Inventory({super.key, super.onShow, super.onHide});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late List<String> itemNames;
  late List<String> itemSKUs;
  late List<int> itemQuantities;

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

    itemNames = ["hello", "world"];
    itemSKUs = ["123", "456"];
    itemQuantities = [1, 2];
  }

  @override
  Widget build(BuildContext context) {
    print("Inventory::build");
    return ListView.separated(
        itemBuilder: (context, index) {
          double iconSize = 20;
          return ListTile(
            title: Text(itemNames[index], style: darkText(context)),
            subtitle: Text("SKU: ${itemSKUs[index]}", style: darkText(context)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  iconSize: iconSize,
                  color: isDark(context) ? Colors.white : Colors.black,
                  onPressed: () {
                    setState(() {
                      itemQuantities[index] = max(0, itemQuantities[index] - 1);
                    });
                  },
                ),
                PlatformTextButton(
                  child: PlatformText(
                    itemQuantities[index].toString(),
                    style: darkText(context).copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () async {
                    String? s = await _showQuickQuantityDialog(
                        context, itemQuantities[index].toString());
                    print(s);
                    if (s == null) return;
                    int? i = int.tryParse(s);
                    if (i == null || i < 0) {
                      simpleSnackbar(context, "Invalid quantity",
                          icon: Icons.error);
                      return;
                    }
                    setState(() {
                      itemQuantities[index] = i;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: iconSize,
                  color: isDark(context) ? Colors.white : Colors.black,
                  onPressed: () {
                    setState(() {
                      itemQuantities[index] = itemQuantities[index] + 1;
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
          );
        },
        itemCount: itemNames.length);
  }

  Future<String?> _showQuickQuantityDialog(BuildContext ctx, String ini) async {
    String? result;

    TextEditingController controller = TextEditingController(
      text: ini,
    );

    await showPlatformDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Quantity"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Quantity",
                  labelText: "Enter the new quantity",
                ),
                onEditingComplete: () {
                  Navigator.of(context).pop();
                  result = controller.text;
                },
              ),
            ],
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
    return result;
  }
}
