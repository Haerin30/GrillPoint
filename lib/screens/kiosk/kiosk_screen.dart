import 'package:flutter/material.dart';

import '../../formatters/currency.dart';
import '../../models/order.dart';
import '../../models/kiosk_cart.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

enum _KioskStep { menu, cart, review, confirmed }

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  final _cart = KioskCart(catalog: () => ProductService.instance.products);
  final _tableController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ProductCategory? _category;
  OrderType _orderType = OrderType.dineIn;
  _KioskStep _step = _KioskStep.menu;

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  void _change(VoidCallback action) => setState(action);

  void _review() {
    if (!_formKey.currentState!.validate()) return;
    if (!_checkCart()) return;
    FocusScope.of(context).unfocus();
    _change(() => _step = _KioskStep.review);
  }

  bool _checkCart() {
    final changed = _cart.reconcile();
    if (changed || _cart.items.isEmpty) {
      _change(() => _step = _KioskStep.cart);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu availability changed. Please check your cart.'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _KioskStep.menu || _step == _KioskStep.confirmed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _change(
            () => _step = _step == _KioskStep.review
                ? _KioskStep.cart
                : _KioskStep.menu,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GrillPoint'),
          leading: IconButton(
            tooltip: 'Exit Kiosk Preview',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('KIOSK PREVIEW • LOCAL DEMO'),
                  const SizedBox(height: 12),
                  ...switch (_step) {
                    _KioskStep.menu => _menu(context),
                    _KioskStep.cart => _cartView(context),
                    _KioskStep.review => _reviewView(context),
                    _KioskStep.confirmed => _confirmation(context),
                  },
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _step == _KioskStep.menu
            ? SafeArea(
                minimum: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _cart.items.isEmpty
                      ? null
                      : () => _change(() => _step = _KioskStep.cart),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'View cart • ${_cart.itemCount} items • ${formatPesos(_cart.total)}',
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
  );

  List<Widget> _menu(BuildContext context) {
    final products = ProductService.instance.products.where(
      (product) =>
          _cart.canOrder(product) &&
          (_category == null || product.category == _category),
    );
    return [
      _heading('Welcome! What are you craving?'),
      const Text('Fresh off the grill. Build your order below.'),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _category == null,
            onSelected: (_) => _change(() => _category = null),
          ),
          for (final category in ProductCategory.values)
            ChoiceChip(
              label: Text(category.label),
              selected: _category == category,
              onSelected: (_) => _change(() => _category = category),
            ),
        ],
      ),
      const SizedBox(height: 20),
      if (products.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No available products in this category. Try another category.',
          ),
        ),
      for (final product in products)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(product.category.label),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      formatPesos(product.price),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    FilledButton.icon(
                      key: ValueKey('add-${product.id}'),
                      onPressed: () => _change(() {
                        _cart.add(product.id);
                      }),
                      icon: const Icon(Icons.add),
                      label: Text('Add ${product.name}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _cartView(BuildContext context) => [
    _heading('Your cart'),
    TextButton.icon(
      onPressed: () => _change(() => _step = _KioskStep.menu),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Back to menu'),
    ),
    if (_cart.items.isEmpty)
      const Text('Your cart is empty. Add something delicious!'),
    for (final item in _cart.items)
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${formatPesos(item.product.price)} each • Subtotal ${formatPesos(item.subtotal)}',
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Decrease ${item.product.name}',
                    onPressed: () =>
                        _change(() => _cart.decrease(item.product.id)),
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '${item.quantity}',
                    key: ValueKey('quantity-${item.product.id}'),
                  ),
                  IconButton(
                    tooltip: 'Increase ${item.product.name}',
                    onPressed: () => _change(() {
                      _cart.add(item.product.id);
                    }),
                    icon: const Icon(Icons.add),
                  ),
                  TextButton(
                    onPressed: () =>
                        _change(() => _cart.remove(item.product.id)),
                    child: Text('Remove ${item.product.name}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    _totals(),
    const SizedBox(height: 24),
    Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like your order?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              for (final type in OrderType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _orderType == type,
                  onSelected: (_) => _change(() => _orderType = type),
                ),
            ],
          ),
          if (_orderType == OrderType.dineIn) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _tableController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Table number',
                helperText: 'Enter a positive whole number.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                final number = int.tryParse(text);
                return !RegExp(r'^\d+$').hasMatch(text) ||
                        number == null ||
                        number <= 0
                    ? 'Enter a valid table number (1 or higher).'
                    : null;
              },
            ),
          ],
        ],
      ),
    ),
    const SizedBox(height: 24),
    FilledButton(
      onPressed: _cart.items.isEmpty ? null : _review,
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text('Review order'),
      ),
    ),
  ];

  Widget _totals() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      '${_cart.itemCount} items • Total ${formatPesos(_cart.total)}',
      key: const ValueKey('cart-total'),
      style: Theme.of(context).textTheme.titleLarge,
    ),
  );

  List<Widget> _reviewView(BuildContext context) => [
    _heading('Review your order'),
    Text(
      _orderType == OrderType.dineIn
          ? 'Dine In • Table ${int.parse(_tableController.text.trim())}'
          : 'Take Out',
    ),
    const SizedBox(height: 16),
    for (final item in _cart.items)
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item.product.name),
        subtitle: Text('${item.quantity} × ${formatPesos(item.product.price)}'),
        trailing: Text(formatPesos(item.subtotal)),
      ),
    _totals(),
    const Text(
      'Demo only. Nothing will be sent to staff or saved permanently. No payment is collected.',
    ),
    const SizedBox(height: 24),
    OutlinedButton(
      onPressed: () => _change(() => _step = _KioskStep.cart),
      child: const Text('Edit order'),
    ),
    const SizedBox(height: 12),
    FilledButton(
      onPressed: () {
        if (_checkCart()) _change(() => _step = _KioskStep.confirmed);
      },
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text('Confirm demo order'),
      ),
    ),
  ];

  List<Widget> _confirmation(BuildContext context) => [
    const Icon(Icons.check_circle_outline, size: 72),
    const SizedBox(height: 20),
    _heading('Demo order preview complete'),
    const Text(
      'This was a local preview only. Your order was not sent to staff or a server and was not saved permanently. No payment was taken.',
    ),
    _totals(),
    FilledButton(
      onPressed: () => _change(() {
        _cart.clear();
        _tableController.clear();
        _category = null;
        _orderType = OrderType.dineIn;
        _step = _KioskStep.menu;
      }),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text('Start new order'),
      ),
    ),
  ];
}
