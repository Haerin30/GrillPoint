import 'package:flutter_test/flutter_test.dart';
import 'package:grillpoint/formatters/currency.dart';
import 'package:grillpoint/models/order.dart';

void main() {
  test('peso amounts have two decimal places and thousands separators', () {
    expect(formatPesos(0), '₱0.00');
    expect(formatPesos(85), '₱85.00');
    expect(formatPesos(1234567.5), '₱1,234,567.50');
    expect(formatPesos(12.345), '₱12.35');
  });

  test(
    'order lifecycle can advance and reverse without passing its endpoints',
    () {
      var status = OrderStatus.queue;
      expect(status.previous, isNull);
      status = status.next!;
      expect(status, OrderStatus.cooking);
      status = status.next!;
      expect(status, OrderStatus.done);
      expect(status.next, isNull);
      status = status.previous!;
      expect(status, OrderStatus.cooking);
      expect(status.previous, OrderStatus.queue);
    },
  );
}
