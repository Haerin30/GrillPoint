import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grillpoint/app/app.dart';
import 'package:grillpoint/app/theme.dart';
import 'package:grillpoint/models/product.dart';
import 'package:grillpoint/screens/kiosk/kiosk_screen.dart';
import 'package:grillpoint/services/product_service.dart';

void main() {
  late List<Product> originalProducts;

  setUp(() {
    originalProducts = List.of(ProductService.instance.products);
    ProductService.instance.products
      ..clear()
      ..addAll([
        Product(
          id: 'bbq',
          name: 'Test BBQ',
          price: 85,
          category: ProductCategory.bbq,
        ),
        Product(
          id: 'drink',
          name: 'Test Drink',
          price: 30,
          category: ProductCategory.drinks,
        ),
        Product(
          id: 'hidden',
          name: 'Unavailable Rice',
          price: 35,
          category: ProductCategory.rice,
          isAvailable: false,
        ),
      ]);
  });

  tearDown(() {
    ProductService.instance.products
      ..clear()
      ..addAll(originalProducts);
  });

  Future<void> open(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? GrillPointTheme.darkTheme : GrillPointTheme.lightTheme,
        home: const KioskScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> addAndOpenCart(WidgetTester tester) async {
    await tapText(tester, 'Add Test BBQ');
    await tester.tap(find.text('View cart • 1 items • ₱85.00'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with available products and filters categories', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Welcome! What are you craving?'), findsOneWidget);
    expect(find.text('Test BBQ'), findsOneWidget);
    expect(find.text('Test Drink'), findsOneWidget);
    expect(find.text('Unavailable Rice'), findsNothing);
    expect(find.byKey(const ValueKey('add-hidden')), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Drinks'));
    await tester.pumpAndSettle();
    expect(find.text('Test BBQ'), findsNothing);
    expect(find.text('Test Drink'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sides'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No available products in this category. Try another category.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Test BBQ'), findsOneWidget);
  });

  testWidgets('cart controls update quantity, subtotal and total', (
    tester,
  ) async {
    await open(tester);
    await addAndOpenCart(tester);
    expect(find.text('1 items • Total ₱85.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase Test BBQ'));
    await tester.pumpAndSettle();
    expect(find.text('2 items • Total ₱170.00'), findsOneWidget);
    expect(find.text('₱85.00 each • Subtotal ₱170.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Decrease Test BBQ'));
    await tester.pumpAndSettle();
    expect(find.text('1 items • Total ₱85.00'), findsOneWidget);
    await tapText(tester, 'Remove Test BBQ');
    expect(find.text('0 items • Total ₱0.00'), findsOneWidget);
    expect(
      find.text('Your cart is empty. Add something delicious!'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Review order'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('Dine In requires a valid table and review can be edited', (
    tester,
  ) async {
    await open(tester);
    await addAndOpenCart(tester);
    for (final invalid in ['', '0', '-2', '1.5', 'abc']) {
      await tester.enterText(find.byType(TextFormField), invalid);
      await tapText(tester, 'Review order');
      expect(
        find.text('Enter a valid table number (1 or higher).'),
        findsOneWidget,
      );
      expect(find.text('Review your order'), findsNothing);
    }
    await tester.enterText(find.byType(TextFormField), '12');
    await tapText(tester, 'Review order');
    expect(find.text('Dine In • Table 12'), findsOneWidget);
    expect(find.text('1 × ₱85.00'), findsOneWidget);
    expect(find.text('₱85.00'), findsOneWidget);
    await tapText(tester, 'Edit order');
    expect(find.text('Your cart'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '12',
    );
  });

  testWidgets('Take Out skips table and demo confirmation resets the session', (
    tester,
  ) async {
    await open(tester, dark: true);
    await addAndOpenCart(tester);
    await tapText(tester, 'Take Out');
    expect(find.byType(TextFormField), findsNothing);
    await tapText(tester, 'Review order');
    expect(find.text('Review your order'), findsOneWidget);
    expect(find.text('Take Out'), findsOneWidget);
    await tapText(tester, 'Confirm demo order');
    expect(find.text('Demo order preview complete'), findsOneWidget);
    expect(
      find.text(
        'This was a local preview only. Your order was not sent to staff or a server and was not saved permanently. No payment was taken.',
      ),
      findsOneWidget,
    );
    await tapText(tester, 'Start new order');
    expect(find.text('View cart • 0 items • ₱0.00'), findsOneWidget);
    expect(find.text('Welcome! What are you craving?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation rejects a product made unavailable after review', (
    tester,
  ) async {
    await open(tester);
    await addAndOpenCart(tester);
    await tapText(tester, 'Take Out');
    await tapText(tester, 'Review order');
    ProductService.instance.products.first.isAvailable = false;
    await tapText(tester, 'Confirm demo order');
    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Demo order preview complete'), findsNothing);
    expect(find.text('0 items • Total ₱0.00'), findsOneWidget);
  });

  testWidgets('dashboard opens and exits Kiosk Preview', (tester) async {
    await tester.pumpWidget(const GrillPointApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tapText(tester, 'Kiosk Preview');
    expect(find.byType(KioskScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Exit Kiosk Preview'));
    await tester.pumpAndSettle();
    expect(find.byType(KioskScreen), findsNothing);
    expect(find.text('Show Orders'), findsOneWidget);
  });
}
