import 'package:flutter/material.dart';
import '../theme/app_theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppThemeController.mode,
        builder: (context, selectedMode, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'अपनी पसंद के अनुसार ऐप की Theme चुनें।',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _themeOption(
                context,
                title: 'Light Mode',
                subtitle: 'हल्की और सफेद Theme',
                icon: Icons.light_mode_rounded,
                value: ThemeMode.light,
                selected: selectedMode,
              ),
              _themeOption(
                context,
                title: 'Dark Mode',
                subtitle: 'गहरी और आरामदायक Theme',
                icon: Icons.dark_mode_rounded,
                value: ThemeMode.dark,
                selected: selectedMode,
              ),
              _themeOption(
                context,
                title: 'System Default',
                subtitle: 'फोन की Theme के अनुसार',
                icon: Icons.phone_android_rounded,
                value: ThemeMode.system,
                selected: selectedMode,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline_rounded),
                title: Text('Chat Action Buttons'),
                subtitle: Text(
                  'Chat के interactive buttons Dark Style में ही रहेंगे।',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode selected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: RadioListTile<ThemeMode>(
        value: value,
        groupValue: selected,
        onChanged: (newValue) {
          if (newValue != null) {
            AppThemeController.setMode(newValue);
          }
        },
        secondary: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
