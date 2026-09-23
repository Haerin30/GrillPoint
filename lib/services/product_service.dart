import '../models/product.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Chicken BBQ',
      price: 85,
      category: ProductCategory.bbq,
    ),
    Product(
      id: '2',
      name: 'Pork BBQ',
      price: 90,
      category: ProductCategory.bbq,
    ),
    Product(id: '3', name: 'Isaw', price: 50, category: ProductCategory.bbq),
    Product(
      id: '4',
      name: 'Pork Liempo',
      price: 120,
      category: ProductCategory.bbq,
    ),
    Product(
      id: '5',
      name: 'Java Rice',
      price: 35,
      category: ProductCategory.rice,
    ),
    Product(id: '6', name: 'Coke', price: 30, category: ProductCategory.drinks),
    Product(
      id: '7',
      name: 'Sprite',
      price: 30,
      category: ProductCategory.drinks,
    ),
  ];
}
