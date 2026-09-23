import 'package:flutter/material.dart';

import '../../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final nameController = TextEditingController();
  final tableController = TextEditingController();
  final orderController = TextEditingController();

  OrderType selectedOrderType = OrderType.dineIn;

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
      name: name,
      tableNumber: selectedOrderType == OrderType.dineIn ? table : null,
      orderNumber: order,
      orderType: selectedOrderType,
    );

    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Padding(
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
              items: const [
                DropdownMenuItem(
                  value: OrderType.dineIn,
                  child: Text('Dine In'),
                ),
                DropdownMenuItem(
                  value: OrderType.takeOut,
                  child: Text('Take Out'),
                ),
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
                child: const Text('Save Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
