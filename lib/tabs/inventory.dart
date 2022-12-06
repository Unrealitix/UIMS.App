import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Use FutureBuilder to show a loading indicator while waiting for the items to load
    print("Inventory::build");
    const double topBarElevation = 2;
    const double roundedCorners = 4;

    return Stack(
      children: [
        RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: _refreshList,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                floating: true,
                backgroundColor: Colors.transparent,
                titleSpacing: 3,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(roundedCorners),
                        ),
                        elevation: topBarElevation,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).backgroundColor,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(roundedCorners),
                              ),
                            ),
                            hintText: AppLocalizations.of(context)!
                                .itemListSearchbarHint,
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.all(0),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      FocusScope.of(context).unfocus();
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (String s) {
                            setState(() {}); //This is to update the suffix icon
                          },
                        ),
                      ),
                    ),
                    //round inline filter button
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .itemListFilterButtonTooltip,
                          child: RawMaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(roundedCorners),
                            ),
                            elevation: topBarElevation,
                            fillColor: Theme.of(context).backgroundColor,
                            child: const Icon(Icons.filter_alt),
                            onPressed: () {
                              print("Filter button pressed");
                            },
                          ),
                        ),
                      ),
                    ),
                    //round inline sort button
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .itemListSortButtonTooltip,
                          child: RawMaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(roundedCorners),
                            ),
                            elevation: topBarElevation,
                            fillColor: Theme.of(context).backgroundColor,
                            child: const Icon(Icons.sort),
                            onPressed: () {
                              print("Sort button pressed");
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    double iconSize = 20;
                    Color iconColor = isCupertino(context)
                        ? CupertinoColors.systemBlue
                        : isDark(context)
                            ? Colors.white
                            : Colors.black;
                    return Column(
                      children: [
                        ListTile(
                          title:
                              Text(items[index].name, style: darkText(context)),
                          subtitle: Text(
                              AppLocalizations.of(context)!
                                  .inventoryListItemSubtitle(items[index].sku),
                              style: darkText(context)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: AppLocalizations.of(context)!
                                    .inventoryListItemDecreaseQuantityTooltip,
                                icon: Icon(Icons.remove, color: iconColor),
                                iconSize: iconSize,
                                color: isDark(context)
                                    ? Colors.white
                                    : Colors.black,
                                onPressed: () {
                                  setState(() {
                                    items[index].changeQuantityTo(
                                        max(0, items[index].quantity - 1));
                                  });
                                },
                              ),
                              Tooltip(
                                message: AppLocalizations.of(context)!
                                    .inventoryListItemSpecificQuantityTooltip,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: (isDark(context)
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    int? i = await _showQuickQuantityDialog(
                                        context,
                                        items[index].quantity.toString());
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
                              ),
                              IconButton(
                                tooltip: AppLocalizations.of(context)!
                                    .inventoryListItemIncreaseQuantityTooltip,
                                icon: Icon(Icons.add, color: iconColor),
                                iconSize: iconSize,
                                color: isDark(context)
                                    ? Colors.white
                                    : Colors.black,
                                onPressed: () {
                                  setState(() {
                                    items[index].changeQuantityTo(
                                        items[index].quantity + 1);
                                  });
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            print("Tapped");
                            _showItemDetails(context, items[index]);
                          },
                        ),
                        if (index != items.length - 1)
                          const Divider(
                            indent: 8,
                            endIndent: 8,
                            height: 0,
                            thickness: 1,
                          )
                        else
                          const SizedBox(height: 64),
                      ],
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.inventoryFABTooltip,
              onPressed: () async {
                Item? ni = await Item.dialogNewItem(context);
                if (ni == null || ni.name.isEmpty || ni.sku.isEmpty) return;
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
              title:
                  Text(AppLocalizations.of(context)!.quickQuantityDialogTitle),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)!.quickQuantityDialogHint,
                  labelText:
                      AppLocalizations.of(context)!.quickQuantityDialogLabel,
                  counterText: AppLocalizations.of(context)!
                      .quickQuantityDialogCounterText(initial),
                  errorText: errorMessage,
                ),
                style: darkText(context),
                onEditingComplete: () => attemptChange(setDialogState),
              ),
              actions: [
                PlatformDialogAction(
                  child: Text(AppLocalizations.of(context)!.dialogCancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    result = null;
                  },
                ),
                PlatformDialogAction(
                  child: Text(AppLocalizations.of(context)!.dialogOk),
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
    //TODO: Improve styling here
    showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: Text(item.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${AppLocalizations.of(context)!.itemPropertySKU}: ${item.sku}"),
                Text(
                    "${AppLocalizations.of(context)!.itemPropertyQuantity}: ${item.quantity}"),
                if (item.barcode != null && item.barcode!.isNotEmpty)
                  Text(
                      "${AppLocalizations.of(context)!.itemPropertyBarcode}: ${item.barcode}"),
                if (item.supplier != null && item.supplier!.isNotEmpty)
                  Text(
                      "${AppLocalizations.of(context)!.itemPropertySupplier}: ${item.supplier}"),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                      "${AppLocalizations.of(context)!.itemPropertyDescription}: ${item.description}"),
              ],
            ),
          ),
          actions: [
            PlatformDialogActionButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit),
                  Text(" ${AppLocalizations.of(context)!.dialogEdit}"),
                ],
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Item? ni = await Item.dialogEditItem(context, item);
                if (ni == null || ni.sku.isEmpty || ni.name.isEmpty) return;
                if (ni.toDelete) {
                  setState(() => items.remove(item));
                  return;
                }
                Item.changeItemOnServer(ni);
                setState(() {
                  items[items.indexOf(item)] = ni;
                });
              },
            ),
            PlatformDialogActionButton(
              child: Text(AppLocalizations.of(context)!.dialogClose),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
