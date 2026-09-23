import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grillpoint/app/app.dart';
import 'package:grillpoint/models/product.dart';
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
      'added product remains after leaving Products and opening it again',
      (tester) async {
        final productService = ProductService.instance;

        productService.products.removeWhere(
          (product) => product.name == 'Test BBQ',
        );

        try {
          await tester.pumpWidget(const GrillPointApp());
          await tester.pumpAndSettle();

          // Open the navigation drawer.
          await tester.tap(find.byIcon(Icons.menu));
          await tester.pumpAndSettle();

          // Open Products.
          await tester.tap(find.text('Products'));
          await tester.pumpAndSettle();

          expect(find.text('Products'), findsOneWidget);

          // Add a product through the UI.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          final textFields = find.byType(TextField);

          await tester.enterText(textFields.at(0), 'Test BBQ');

          await tester.enterText(textFields.at(1), '99');

          await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
          await tester.pumpAndSettle();

          expect(find.text('Test BBQ'), findsOneWidget);

          // Return to the Dashboard.
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();

          expect(find.text('GrillPoint'), findsOneWidget);

          // Open the drawer again.
          await tester.tap(find.byIcon(Icons.menu));
          await tester.pumpAndSettle();

          // Open Products again.
          await tester.tap(find.text('Products'));
          await tester.pumpAndSettle();

          // A new ProductMenuScreen instance should still show the product.
          expect(find.text('Products'), findsOneWidget);
          expect(find.text('Test BBQ'), findsOneWidget);
        } finally {
          // Prevent this test from affecting other tests.
          productService.products.removeWhere(
            (product) => product.name == 'Test BBQ',
          );
        }
      },
    );
  });

  group('Order status and Undo', () {
    testWidgets(
      'swiping an order moves it to Cooking and Undo restores Queue',
      (tester) async {
        await tester.pumpWidget(const GrillPointApp());
        await tester.pumpAndSettle();

        final queueSection = find.byKey(const ValueKey('queue-section'));

        final cookingSection = find.byKey(const ValueKey('cooking-section'));

        // Juan initially belongs to Queue.
        expect(
          find.descendant(
            of: queueSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: cookingSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsNothing,
        );

        // Find Juan's card inside Queue.
        final juanCard = find.ancestor(
          of: find.descendant(
            of: queueSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          matching: find.byType(Card),
        );

        expect(juanCard, findsOneWidget);

        // Swipe Juan from Queue -> Cooking.
        await tester.drag(juanCard, const Offset(500, 0));
        await tester.pumpAndSettle();

        // Juan must now be in Cooking.
        expect(
          find.descendant(
            of: queueSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsNothing,
        );

        expect(
          find.descendant(
            of: cookingSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsOneWidget,
        );

        // Undo the status change.
        expect(find.text('UNDO'), findsOneWidget);

        await tester.tap(find.text('UNDO'));
        await tester.pumpAndSettle();

        // Juan must be restored to Queue.
        expect(
          find.descendant(
            of: queueSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: cookingSection,
            matching: find.text('Juan Dela Cruz'),
          ),
          findsNothing,
        );
      },
    );
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
