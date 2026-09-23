import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  String getThemeName() {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(getThemeName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Choose Theme'),
                    children: [
                      RadioGroup<ThemeMode>(
                        groupValue: themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            onThemeChanged(value);
                            Navigator.pop(context);
                          }
                        },
                        child: Column(
                          children: [
                            const RadioListTile<ThemeMode>(
                              title: Text('Light'),
                              value: ThemeMode.light,
                            ),
                            const RadioListTile<ThemeMode>(
                              title: Text('Dark'),
                              value: ThemeMode.dark,
                            ),
                            const RadioListTile<ThemeMode>(
                              title: Text('System'),
                              value: ThemeMode.system,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
