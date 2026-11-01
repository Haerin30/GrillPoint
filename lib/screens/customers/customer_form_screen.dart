import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/order.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final Customer? customer;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  late final TextEditingController nameController;
  late final TextEditingController tableController;
  late final TextEditingController orderController;
  late OrderType selectedOrderType;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    nameController = TextEditingController(text: customer?.name ?? '');
    tableController = TextEditingController(text: customer?.tableNumber ?? '');
    orderController = TextEditingController(text: customer?.orderNumber ?? '');
    selectedOrderType = customer?.orderType ?? OrderType.dineIn;
  }

  @override
  void dispose() {
    nameController.dispose();
    tableController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void saveCustomer() {
    final name = nameController.text.trim();
    final table = tableController.text.trim();
    final order = orderController.text.trim();

    if (name.isEmpty || order.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (selectedOrderType == OrderType.dineIn && table.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a table number')),
      );
      return;
    }

    final customer = Customer(
      id:
          widget.customer?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      tableNumber: selectedOrderType == OrderType.dineIn ? table : null,
      orderNumber: order,
      orderType: selectedOrderType,
      status: widget.customer?.status ?? OrderStatus.queue,
    );

    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Customer' : 'Add Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<OrderType>(
              initialValue: selectedOrderType,
              decoration: const InputDecoration(
                labelText: 'Order Type',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final type in OrderType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedOrderType = value;

                  if (value == OrderType.takeOut) {
                    tableController.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            if (selectedOrderType == OrderType.dineIn)
              TextField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: 'Table Number',
                  border: OutlineInputBorder(),
                ),
              ),

            if (selectedOrderType == OrderType.dineIn)
              const SizedBox(height: 16),

            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'Order Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveCustomer,
                child: Text(isEditing ? 'Save Changes' : 'Save Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
