import 'package:flutter/material.dart';

import '../../models/customer.dart';
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

  bool queueExpanded = true;
  bool cookingExpanded = true;
  bool doneExpanded = true;

  List<Customer> getCustomersByStatus(OrderStatus status) {
    return customers.where((customer) => customer.status == status).toList();
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

  bool isExpanded(OrderStatus status) {
    switch (status) {
      case OrderStatus.queue:
        return queueExpanded;
      case OrderStatus.cooking:
        return cookingExpanded;
      case OrderStatus.done:
        return doneExpanded;
    }
  }

  void toggleSection(OrderStatus status) {
    setState(() {
      switch (status) {
        case OrderStatus.queue:
          queueExpanded = !queueExpanded;
          break;
        case OrderStatus.cooking:
          cookingExpanded = !cookingExpanded;
          break;
        case OrderStatus.done:
          doneExpanded = !doneExpanded;
          break;
      }
    });
  }

  OrderStatus? getNextStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.queue:
        return OrderStatus.cooking;
      case OrderStatus.cooking:
        return OrderStatus.done;
      case OrderStatus.done:
        return null;
    }
  }

  OrderStatus? getPreviousStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.queue:
        return null;
      case OrderStatus.cooking:
        return OrderStatus.queue;
      case OrderStatus.done:
        return OrderStatus.cooking;
    }
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
      final nextStatus = getNextStatus(customer.status);

      if (nextStatus != null) {
        moveCustomer(customer, nextStatus);
      }
    } else if (direction == DismissDirection.endToStart) {
      final previousStatus = getPreviousStatus(customer.status);

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

    if (newCustomer != null) {
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
    final nextStatus = getNextStatus(customer.status);
    final previousStatus = getPreviousStatus(customer.status);

    return Dismissible(
      key: ValueKey(customer.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (nextStatus == null) {
            return false;
          }
        }

        if (direction == DismissDirection.endToStart) {
          if (previousStatus == null) {
            return false;
          }
        }

        return true;
      },
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
              nextStatus == null ? '' : 'Move to ${getStatusTitle(nextStatus)}',
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
              previousStatus == null
                  ? ''
                  : 'Move to ${getStatusTitle(previousStatus)}',
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
    final expanded = isExpanded(status);

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
                  getStatusTitle(status),
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
