import 'package:flutter/material.dart';

import '../../models/customer.dart';

class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late final TextEditingController nameController;
  late final TextEditingController tableController;
  late final TextEditingController orderController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.customer.name);

    tableController = TextEditingController(text: widget.customer.tableNumber);

    orderController = TextEditingController(text: widget.customer.orderNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    tableController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void saveChanges() {
    final name = nameController.text.trim();
    final table = tableController.text.trim();
    final order = orderController.text.trim();

    if (name.isEmpty || table.isEmpty || order.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final updatedCustomer = Customer(
      name: name,
      tableNumber: table,
      orderNumber: order,
      status: widget.customer.status,
    );

    Navigator.pop(context, updatedCustomer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer')),
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
            TextField(
              controller: tableController,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(),
              ),
            ),
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
                onPressed: saveChanges,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
