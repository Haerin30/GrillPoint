import 'package:flutter_test/flutter_test.dart';

import 'package:grillpoint/models/customer.dart';
import 'package:grillpoint/models/product.dart';
import 'package:grillpoint/services/product_service.dart';

void main() {
  group('Customer model', () {
    test('creates a dine-in customer with a table number', () {
      final customer = Customer(
        id: 'test_001',
        name: 'Juan',
        tableNumber: '5',
        orderNumber: '#001',
        orderType: OrderType.dineIn,
      );

      expect(customer.id, 'test_001');
      expect(customer.name, 'Juan');
      expect(customer.tableNumber, '5');
      expect(customer.orderNumber, '#001');
      expect(customer.orderType, OrderType.dineIn);
      expect(customer.status, OrderStatus.queue);
    });

    test('creates a take-out customer without a table number', () {
      final customer = Customer(
        id: 'test_002',
        name: 'Maria',
        orderNumber: '#002',
        orderType: OrderType.takeOut,
      );

      expect(customer.id, 'test_002');
      expect(customer.tableNumber, isNull);
      expect(customer.orderType, OrderType.takeOut);
    });

    test('customer status can move through the order flow', () {
      final customer = Customer(
        id: 'test_003',
        name: 'Pedro',
        orderNumber: '#003',
        orderType: OrderType.dineIn,
        tableNumber: '3',
      );

      expect(customer.status, OrderStatus.queue);

      customer.status = OrderStatus.cooking;
      expect(customer.status, OrderStatus.cooking);

      customer.status = OrderStatus.done;
      expect(customer.status, OrderStatus.done);
    });
  });

  group('ProductService', () {
    test('contains the sample products', () {
      final products = ProductService.instance.products;

      expect(products, isNotEmpty);
      expect(
        products.any((product) => product.name == 'Chicken BBQ'),
        isTrue,
      );
    });

    test('products have valid prices and categories', () {
      final products = ProductService.instance.products;

      for (final product in products) {
        expect(product.price, greaterThan(0));
        expect(product.category, isA<ProductCategory>());
      }
    });

    test('product availability can be changed', () {
      final products = ProductService.instance.products;
      final product = products.first;

      final originalAvailability = product.isAvailable;

      product.isAvailable = !originalAvailability;

      expect(product.isAvailable, !originalAvailability);

      product.isAvailable = originalAvailability;
    });
  });
}