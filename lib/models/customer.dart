import 'order.dart';

/// Staff-entered walk-in record; not yet a persisted order with line items.
class Customer {
  final String id;

  String name;
  String? tableNumber;
  String orderNumber;
  OrderType orderType;
  OrderStatus status;

  Customer({
    required this.id,
    required this.name,
    required this.orderNumber,
    required this.orderType,
    this.tableNumber,
    this.status = OrderStatus.queue,
  });
}
