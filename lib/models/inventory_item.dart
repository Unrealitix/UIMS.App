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
}
