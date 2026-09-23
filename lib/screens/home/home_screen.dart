import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../customers/add_customer_screen.dart';
import '../customers/edit_customer_screen.dart';
import '../orders/customer_order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Customer> customers = [
    Customer(
      name: 'Juan Dela Cruz',
      tableNumber: 'Table 1',
      orderNumber: '#001',
    ),
    Customer(name: 'Maria Santos', tableNumber: 'Table 2', orderNumber: '#002'),
    Customer(
      name: 'Pedro Reyes',
      tableNumber: 'Table 3',
      orderNumber: '#003',
      status: OrderStatus.cooking,
    ),
    Customer(
      name: 'Ana Garcia',
      tableNumber: 'Table 4',
      orderNumber: '#004',
      status: OrderStatus.done,
    ),
  ];

  List<Customer> getCustomersByStatus(OrderStatus status) {
    return customers.where((customer) {
      return customer.status == status;
    }).toList();
  }

  String getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.queue:
        return 'QUEUE';
      case OrderStatus.cooking:
        return 'COOKING';
      case OrderStatus.done:
        return 'DONE';
    }
  }

  void addCustomer() async {
    final Customer? newCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
    );

    if (newCustomer != null) {
      setState(() {
        customers.add(newCustomer);
      });
    }
  }

  void editCustomer(Customer customer) async {
    final Customer? updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(customer: customer),
      ),
    );

    if (updatedCustomer != null) {
      setState(() {
        final index = customers.indexOf(customer);

        if (index != -1) {
          customers[index] = updatedCustomer;
        }
      });
    }
  }

  void deleteCustomer(Customer customer) {
    setState(() {
      customers.remove(customer);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${customer.name} deleted')));
  }

  void openCustomerOrder(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerOrderScreen(customer: customer),
      ),
    );
  }

  Widget buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${customer.tableNumber} • ${customer.orderNumber}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              editCustomer(customer);
            } else if (value == 'delete') {
              deleteCustomer(customer);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit Customer')),
            PopupMenuItem(value: 'delete', child: Text('Delete Customer')),
          ],
        ),
        onTap: () {
          openCustomerOrder(customer);
        },
      ),
    );
  }

  Widget buildStatusSection(OrderStatus status) {
    final statusCustomers = getCustomersByStatus(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getStatusTitle(status),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (statusCustomers.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text('No customers', style: TextStyle(color: Colors.grey)),
          )
        else
          ...statusCustomers.map(buildCustomerCard),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GrillPoint',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildStatusSection(OrderStatus.queue),
          buildStatusSection(OrderStatus.cooking),
          buildStatusSection(OrderStatus.done),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
