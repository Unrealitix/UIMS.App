import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/inventory_item.dart';

enum _SortBy {
  alphabeticalAscending,
  alphabeticalDescending,
  quantityAscending,
  quantityDescending,
}

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  List<Item> items = [];
  final TextEditingController _searchController = TextEditingController();

  _SortBy sortBy = _SortBy.alphabeticalAscending;

  bool filterOn = false;

  String sortByString(_SortBy sb) {
    switch (sb) {
      case _SortBy.alphabeticalAscending:
        return AppLocalizations.of(context)!
            .itemSortOptionAlphabeticalAscending;
      case _SortBy.alphabeticalDescending:
        return AppLocalizations.of(context)!
            .itemSortOptionAlphabeticalDescending;
      case _SortBy.quantityAscending:
        return AppLocalizations.of(context)!.itemSortOptionQuantityAscending;
      case _SortBy.quantityDescending:
        return AppLocalizations.of(context)!.itemSortOptionQuantityDescending;
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint("Inventory::initState");

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      setState(() {
        sortBy = _SortBy.values[prefs.getInt("sort_by") ?? 0];
      });
      _refreshList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Use FutureBuilder to show a loading indicator while waiting for the items to load
    debugPrint("Inventory::build");
    const double topBarElevation = 2;
    const double roundedCorners = 4;

    void searchItems(String s) {
      items = Item.globalItems
          .where((item) => item.name.toLowerCase().contains(s.toLowerCase()))
          .toList();
    }

    return Stack(
      children: [
        RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: _refreshList,
          child: Scrollbar(
            interactive: true,
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
                            //TODO: Integrate this text colour into global theme
                            style: const TextStyle(color: Colors.white),
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              filled: true,
                              //TODO: Fix searchbar background colour in light mode:
                              fillColor: Theme.of(context).cardColor,
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
                                        searchItems("");
                                        FocusScope.of(context).unfocus();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (String s) {
                              setState(() {
                                searchItems(s);
                              });
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
                              fillColor: filterOn
                                  ? mainColour
                                  : Theme.of(context).cardColor,
                              child: filterOn
                                  ? const Icon(Icons.filter_alt)
                                  : const Icon(Icons.filter_alt_off),
                              onPressed: () {
                                debugPrint("Filter button pressed");
                                setState(() {
                                  filterOn = !filterOn;
                                });
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
                              fillColor: Theme.of(context).cardColor,
                              child: const Icon(Icons.sort),
                              onPressed: () {
                                _changeSortDialog(context);
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
                      return Column(
                        children: [
                          ListTile(
                            title: Text(items[index].name),
                            subtitle: Text(AppLocalizations.of(context)!
                                .inventoryListItemSubtitle(items[index].sku)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: AppLocalizations.of(context)!
                                      .inventoryListItemDecreaseQuantityTooltip,
                                  icon: const Icon(Icons.remove),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      int? i = await _showQuickQuantityDialog(
                                          context,
                                          items[index].quantity.toString());
                                      debugPrint("$i");
                                      if (i == null) return; //Dialog cancelled
                                      setState(() {
                                        items[index].changeQuantityTo(i);
                                      });
                                    },
                                    child: Text(
                                      items[index].quantity.toString(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: AppLocalizations.of(context)!
                                      .inventoryListItemIncreaseQuantityTooltip,
                                  icon: const Icon(Icons.add),
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
                              debugPrint("Tapped");
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
    await Item.getItemsFromServer();
    setState(() {
      items = Item.globalItems;
    });
    _sortItems();
  }

  Future<void> _sortItems() async {
    debugPrint("Sorting items by $sortBy");
    setState(() {
      switch (sortBy) {
        case _SortBy.alphabeticalAscending:
          items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case _SortBy.alphabeticalDescending:
          items.sort((a, b) => b.name.compareTo(a.name));
          break;
        case _SortBy.quantityAscending:
          items.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
        case _SortBy.quantityDescending:
          items.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
      }
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
          errorMessage =
              AppLocalizations.of(context)!.itemNewDialogQuantityInvalidWarning;
        } else {
          errorMessage = null;
          Navigator.of(context).pop();
        }
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
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
                onEditingComplete: () => attemptChange(setDialogState),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.dialogCancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    result = null;
                  },
                ),
                TextButton(
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
    showDialog(
      context: context,
      builder: (context) {
        const padding = SizedBox(height: 8);
        const bold = TextStyle(fontWeight: FontWeight.bold);
        return AlertDialog(
          title: Text(item.name),
          content: RawScrollbar(
            thickness: 2,
            interactive: false,
            thumbVisibility: true,
            thumbColor: Colors.grey.withOpacity(0.5),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.itemPropertySKU,
                    style: bold,
                  ),
                  Text(item.sku),
                  padding,
                  Text(
                    AppLocalizations.of(context)!.itemPropertyQuantity,
                    style: bold,
                  ),
                  Text(item.quantity.toString()),
                  padding,
                  if (item.barcode != null && item.barcode!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.itemPropertyBarcode,
                          style: bold,
                        ),
                        Text(item.barcode!),
                      ],
                    ),
                  padding,
                  if (item.supplier != null && item.supplier!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.itemPropertySupplier,
                          style: bold,
                        ),
                        Text(item.supplier!),
                      ],
                    ),
                  padding,
                  if (item.description != null && item.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.itemPropertyDescription,
                          style: bold,
                        ),
                        Text(item.description!),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
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
            TextButton(
              child: Text(AppLocalizations.of(context)!.dialogClose),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _changeSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.itemSortDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (_SortBy sb in _SortBy.values)
                    RadioListTile<_SortBy>(
                      title: Text(sortByString(sb)),
                      value: sb,
                      groupValue: sortBy,
                      onChanged: (_SortBy? value) {
                        sortBy = value!;
                        _sortItems();
                        Navigator.of(context).pop();
                        _saveSortSettings();
                      },
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveSortSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("sort_by", sortBy.index);
  }
}
