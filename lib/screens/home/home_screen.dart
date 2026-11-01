import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/order.dart';
import '../../widgets/app_drawer.dart';
import '../customers/add_customer_screen.dart';
import '../customers/edit_customer_screen.dart';
import '../orders/customer_order_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Customer> customers = [
    Customer(
      id: 'customer_001',
      name: 'Juan Dela Cruz',
      tableNumber: '1',
      orderNumber: '#001',
      orderType: OrderType.dineIn,
    ),
    Customer(
      id: 'customer_002',
      name: 'Maria Santos',
      tableNumber: '2',
      orderNumber: '#002',
      orderType: OrderType.dineIn,
    ),
    Customer(
      id: 'customer_003',
      name: 'Pedro Reyes',
      tableNumber: '3',
      orderNumber: '#003',
      orderType: OrderType.dineIn,
      status: OrderStatus.cooking,
    ),
    Customer(
      id: 'customer_004',
      name: 'Ana Garcia',
      orderNumber: '#004',
      orderType: OrderType.takeOut,
      status: OrderStatus.done,
    ),
  ];

  OrderStatus? selectedStatus;

  final Set<OrderStatus> _collapsedStatuses = {};

  List<Customer> getCustomersByStatus(OrderStatus status) {
    return customers.where((customer) => customer.status == status).toList();
  }

  void toggleSection(OrderStatus status) {
    setState(() {
      if (!_collapsedStatuses.add(status)) {
        _collapsedStatuses.remove(status);
      }
    });
  }

  void moveCustomer(Customer customer, OrderStatus newStatus) {
    final customerId = customer.id;
    final oldStatus = customer.status;

    setState(() {
      customer.status = newStatus;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Status updated'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final index = customers.indexWhere(
              (customer) => customer.id == customerId,
            );

            if (index == -1) {
              return;
            }

            setState(() {
              customers[index].status = oldStatus;
            });
          },
        ),
      ),
    );
  }

  void handleSwipe(Customer customer, DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      final nextStatus = customer.status.next;

      if (nextStatus != null) {
        moveCustomer(customer, nextStatus);
      }
    } else if (direction == DismissDirection.endToStart) {
      final previousStatus = customer.status.previous;

      if (previousStatus != null) {
        moveCustomer(customer, previousStatus);
      }
    }
  }

  Future<void> addCustomer() async {
    final Customer? newCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
    );

    if (mounted && newCustomer != null) {
      setState(() {
        customers.add(newCustomer);
      });
    }
  }

  Future<void> editCustomer(Customer customer) async {
    final Customer? updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(customer: customer),
      ),
    );

    if (mounted && updatedCustomer != null) {
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
    final nextStatus = customer.status.next;
    final previousStatus = customer.status.previous;

    return Dismissible(
      key: ValueKey(customer.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async =>
          direction == DismissDirection.startToEnd
          ? nextStatus != null
          : previousStatus != null,
      onDismissed: (direction) {
        handleSwipe(customer, direction);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.arrow_forward, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              nextStatus == null ? '' : 'Move to ${nextStatus.label}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F6FEB),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              previousStatus == null ? '' : 'Move to ${previousStatus.label}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back, color: Colors.white),
          ],
        ),
      ),
      child: Card(
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                customer.orderType == OrderType.dineIn
                    ? 'Dine In • Table ${customer.tableNumber}'
                    : 'Take Out',
              ),
              Text(customer.orderNumber),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.swipe, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe to move status',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
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
      ),
    );
  }

  Widget buildStatusSection(OrderStatus status) {
    if (selectedStatus != null && selectedStatus != status) {
      return const SizedBox.shrink();
    }

    final statusCustomers = getCustomersByStatus(status);
    final expanded = !_collapsedStatuses.contains(status);

    return Column(
      key: ValueKey('${status.name}-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => toggleSection(status),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  status.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${statusCustomers.length})',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          if (statusCustomers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text('No customers', style: TextStyle(color: Colors.grey)),
            )
          else
            ...statusCustomers.map(buildCustomerCard),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      appBar: AppBar(
        title: const Text(
          'GrillPoint',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<OrderStatus?>(
            initialValue: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Show Orders',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<OrderStatus?>(
                value: null,
                child: Text('All Orders'),
              ),
              DropdownMenuItem(value: OrderStatus.queue, child: Text('Queue')),
              DropdownMenuItem(
                value: OrderStatus.cooking,
                child: Text('Cooking'),
              ),
              DropdownMenuItem(value: OrderStatus.done, child: Text('Done')),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 24),
          ...OrderStatus.values.map(buildStatusSection),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
