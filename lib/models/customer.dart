enum OrderStatus { queue, cooking, done }

class Customer {
  String name;
  String tableNumber;
  String orderNumber;
  OrderStatus status;

  Customer({
    required this.name,
    required this.tableNumber,
    required this.orderNumber,
    this.status = OrderStatus.queue,
  });
}
