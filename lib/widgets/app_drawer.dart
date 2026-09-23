import 'package:flutter/material.dart';

import '../screens/products/product_menu_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const AppDrawer({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.restaurant, size: 40),
                SizedBox(height: 8),
                Text(
                  'GrillPoint',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('BBQ POS', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductMenuScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Sales'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    themeMode: themeMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
