import 'product.dart';

/// Session-only cart. The catalog is read on demand so deleted or unavailable
/// products cannot be included in a review or confirmation.
class KioskCart {
  KioskCart({required this.catalog});

  final List<Product> Function() catalog;
  final Map<String, int> _quantities = {};

  List<KioskCartItem> get items => [
    for (final product in catalog())
      if (_quantities.containsKey(product.id) && canOrder(product))
        KioskCartItem(product: product, quantity: _quantities[product.id]!),
  ];

  bool canOrder(Product product) =>
      product.isAvailable && product.price.isFinite && product.price > 0;

  bool add(String productId) {
    final matches = catalog().where((product) => product.id == productId);
    if (matches.isEmpty || !canOrder(matches.first)) return false;
    _quantities.update(
      productId,
      (quantity) => quantity + 1,
      ifAbsent: () => 1,
    );
    return true;
  }

  void decrease(String productId) {
    final quantity = _quantities[productId];
    if (quantity == null) return;
    if (quantity <= 1) {
      remove(productId);
    } else {
      _quantities[productId] = quantity - 1;
    }
  }

  void remove(String productId) => _quantities.remove(productId);
  void clear() => _quantities.clear();

  /// Discard stale selections before reviewing or confirming.
  bool reconcile() {
    final validIds = items.map((item) => item.product.id).toSet();
    final changed = _quantities.keys.any((id) => !validIds.contains(id));
    _quantities.removeWhere((id, _) => !validIds.contains(id));
    return changed;
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

class KioskCartItem {
  const KioskCartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;
  double get subtotal => product.price * quantity;
}
