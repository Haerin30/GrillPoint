/// Shared order concepts used by both staff tools and the customer kiosk.
enum OrderType {
  dineIn('Dine In'),
  takeOut('Take Out');

  const OrderType(this.label);
  final String label;
}

enum OrderStatus {
  queue('QUEUE'),
  cooking('COOKING'),
  done('DONE');

  const OrderStatus(this.label);
  final String label;

  OrderStatus? get next => switch (this) {
    queue => cooking,
    cooking => done,
    done => null,
  };

  OrderStatus? get previous => switch (this) {
    queue => null,
    cooking => queue,
    done => cooking,
  };
}
