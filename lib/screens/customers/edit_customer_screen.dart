import 'package:flutter/material.dart';

import '../../models/customer.dart';
import 'customer_form_screen.dart';

class EditCustomerScreen extends StatelessWidget {
  const EditCustomerScreen({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) => CustomerFormScreen(customer: customer);
}
