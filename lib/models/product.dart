enum ProductCategory { bbq, drinks, sides, rice }

class Product {
  final String id;
  String name;
  double price;
  ProductCategory category;
  bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isAvailable = true,
  });
}
