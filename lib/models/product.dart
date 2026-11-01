enum ProductCategory {
  bbq('BBQ'),
  drinks('Drinks'),
  sides('Sides'),
  rice('Rice');

  const ProductCategory(this.label);
  final String label;
}

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
