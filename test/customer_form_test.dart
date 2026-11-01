import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grillpoint/models/customer.dart';
import 'package:grillpoint/models/order.dart';
import 'package:grillpoint/screens/customers/add_customer_screen.dart';
import 'package:grillpoint/screens/customers/edit_customer_screen.dart';

void main() {
  Future<void> launch(
    WidgetTester tester,
    Widget screen,
    ValueChanged<Customer?> onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                onResult(
                  await Navigator.push<Customer>(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  ),
                );
              },
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('staff add validates required fields and returns a walk-in', (
    tester,
  ) async {
    Customer? result;
    await launch(tester, const AddCustomerScreen(), (value) => result = value);
    await tester.tap(find.text('Save Customer'));
    await tester.pumpAndSettle();
    expect(find.text('Please fill in all required fields'), findsOneWidget);
    // Let the first snackbar close before checking the next validation message.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.enterText(field('Customer Name'), 'Walk-in guest');
    await tester.enterText(field('Order Number'), '#005');
    await tester.tap(find.text('Save Customer'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a table number'), findsOneWidget);
    await tester.enterText(field('Table Number'), '8');
    await tester.tap(find.text('Save Customer'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.name, 'Walk-in guest');
    expect(result!.orderNumber, '#005');
    expect(result!.tableNumber, '8');
    expect(result!.orderType, OrderType.dineIn);
    expect(result!.status, OrderStatus.queue);
  });

  testWidgets('staff edit preserves identity and cooking status for take-out', (
    tester,
  ) async {
    final original = Customer(
      id: 'existing',
      name: 'Guest',
      orderNumber: '#006',
      orderType: OrderType.dineIn,
      tableNumber: '2',
      status: OrderStatus.cooking,
    );
    Customer? result;
    await launch(
      tester,
      EditCustomerScreen(customer: original),
      (value) => result = value,
    );
    expect(
      tester.widget<TextField>(field('Customer Name')).controller!.text,
      'Guest',
    );
    await tester.enterText(field('Customer Name'), 'Updated guest');
    await tester.tap(find.byType(DropdownButtonFormField<OrderType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Out').last);
    await tester.pumpAndSettle();
    expect(field('Table Number'), findsNothing);
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(result!.id, original.id);
    expect(result!.name, 'Updated guest');
    expect(result!.status, OrderStatus.cooking);
    expect(result!.orderType, OrderType.takeOut);
    expect(result!.tableNumber, isNull);
    expect(original.name, 'Guest');
    expect(original.tableNumber, '2');
  });

  testWidgets('leaving edit without saving does not change the staff record', (
    tester,
  ) async {
    final original = Customer(
      id: 'existing',
      name: 'Guest',
      orderNumber: '#007',
      orderType: OrderType.takeOut,
      status: OrderStatus.done,
    );
    Customer? result;
    await launch(
      tester,
      EditCustomerScreen(customer: original),
      (value) => result = value,
    );
    await tester.enterText(field('Customer Name'), 'Unsaved name');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(original.name, 'Guest');
    expect(original.status, OrderStatus.done);
  });
}
