import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grillpoint/app/app.dart';
import 'package:grillpoint/models/product.dart';
import 'package:grillpoint/screens/products/product_menu_screen.dart';
import 'package:grillpoint/services/product_service.dart';

void main() {
  group('GrillPoint smoke test', () {
    testWidgets('application launches and displays the main screen', (
      tester,
    ) async {
      await tester.pumpWidget(const GrillPointApp());
      await tester.pumpAndSettle();

      expect(find.text('GrillPoint'), findsOneWidget);
      expect(find.text('Show Orders'), findsOneWidget);
      expect(find.text('QUEUE'), findsOneWidget);
    });
  });

  group('Product management', () {
    testWidgets(
      'added product remains available after navigating away and returning',
      (tester) async {
        final productService = ProductService.instance;

        productService.products.removeWhere(
          (product) => product.name == 'Test BBQ',
        );

        await tester.pumpWidget(const MaterialApp(home: ProductMenuScreen()));
        await tester.pumpAndSettle();

        // Open Add Product.
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('Add Product'), findsWidgets);

        final textFields = find.byType(TextField);

        await tester.enterText(textFields.at(0), 'Test BBQ');

        await tester.enterText(textFields.at(1), '99');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
        await tester.pumpAndSettle();

        expect(find.text('Test BBQ'), findsOneWidget);

        // Navigate away from the Products screen.
        final productContext = tester.element(find.byType(ProductMenuScreen));

        Navigator.of(productContext).push(
          MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: Center(child: Text('Other Screen'))),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Other Screen'), findsOneWidget);

        // Navigate back to Products.
        Navigator.of(productContext).pop();
        await tester.pumpAndSettle();

        expect(find.text('Products'), findsOneWidget);
        expect(find.text('Test BBQ'), findsOneWidget);

        // Clean up shared test data.
        productService.products.removeWhere(
          (product) => product.name == 'Test BBQ',
        );
      },
    );
  });

  group('Order status and Undo', () {
    testWidgets('swiping an order changes its status and Undo restores it', (
      tester,
    ) async {
      await tester.pumpWidget(const GrillPointApp());
      await tester.pumpAndSettle();

      // Juan starts in Queue.
      expect(find.text('Juan Dela Cruz'), findsOneWidget);

      final customerCard = find.ancestor(
        of: find.text('Juan Dela Cruz'),
        matching: find.byType(Card),
      );

      expect(customerCard, findsOneWidget);

      // Swipe Juan from Queue -> Cooking.
      await tester.drag(customerCard, const Offset(500, 0));
      await tester.pumpAndSettle();

      // The Undo action should appear.
      expect(find.text('UNDO'), findsOneWidget);

      // Undo the status change.
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Juan should still be displayed after returning to Queue.
      expect(find.text('Juan Dela Cruz'), findsOneWidget);

      // Scroll back to the top and verify Queue is still present.
      await tester.scrollUntilVisible(
        find.text('QUEUE'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('QUEUE'), findsOneWidget);
    });
  });

  test('ProductService contains sample products', () {
    final products = ProductService.instance.products;

    expect(products, isNotEmpty);
    expect(products.any((product) => product.name == 'Chicken BBQ'), isTrue);
  });

  test('ProductService products have valid prices and categories', () {
    final products = ProductService.instance.products;

    for (final product in products) {
      expect(product.price, greaterThan(0));
      expect(product.category, isA<ProductCategory>());
    }
  });
}
