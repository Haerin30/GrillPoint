import 'package:flutter_test/flutter_test.dart';
import 'package:grillpoint/models/kiosk_cart.dart';
import 'package:grillpoint/models/product.dart';

void main() {
  late List<Product> products;
  late KioskCart cart;

  setUp(() {
    products = [
      Product(id: 'bbq', name: 'BBQ', price: 85, category: ProductCategory.bbq),
      Product(
        id: 'rice',
        name: 'Rice',
        price: 35,
        category: ProductCategory.rice,
      ),
      Product(
        id: 'sold-out',
        name: 'Sold out',
        price: 50,
        category: ProductCategory.sides,
        isAvailable: false,
      ),
    ];
    cart = KioskCart(catalog: () => products);
  });

  test('adding, increasing, decreasing and removing recalculate totals', () {
    expect(cart.add('bbq'), isTrue);
    cart.add('bbq');
    cart.add('rice');
    expect(cart.itemCount, 3);
    expect(cart.items.first.subtotal, 170);
    expect(cart.total, 205);
    cart.decrease('bbq');
    expect(cart.itemCount, 2);
    expect(cart.total, 120);
    cart.remove('rice');
    expect(cart.total, 85);
    cart.decrease('bbq');
    cart.decrease('bbq');
    cart.decrease('unknown');
    expect(cart.itemCount, 0);
    expect(cart.total, 0);
    expect(products.first.price, 85);
    expect(products, hasLength(3));
  });

  test('unavailable, missing and invalid-price products cannot be ordered', () {
    expect(cart.add('sold-out'), isFalse);
    expect(cart.add('unknown'), isFalse);
    for (final price in [0.0, -1.0, double.nan, double.infinity]) {
      products.first.price = price;
      expect(cart.add('bbq'), isFalse);
    }
    expect(cart.items, isEmpty);
  });

  test('availability changes and deletion invalidate existing selections', () {
    cart.add('bbq');
    cart.add('rice');
    products.first.isAvailable = false;
    products.removeAt(1);
    expect(cart.add('bbq'), isFalse);
    expect(cart.total, 0);
    expect(cart.reconcile(), isTrue);
    products.first.isAvailable = true;
    expect(cart.items, isEmpty);
  });

  test('clear starts an empty cart', () {
    cart.add('bbq');
    cart.clear();
    expect(cart.items, isEmpty);
    expect(cart.total, 0);
  });
}
