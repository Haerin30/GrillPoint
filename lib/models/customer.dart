enum OrderStatus {
  queue,
  cooking,
  done,
}

enum OrderType {
  dineIn,
  takeOut,
}

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