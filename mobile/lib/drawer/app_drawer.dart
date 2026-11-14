import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final Future<void> Function() onLogout;
  final void Function(String route) onNavigate;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.onLogout,
    required this.onNavigate,
  });

  static const Color blue = Color(0xFF2563EB);

  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Home', 'description': 'Go to your AI dashboard', 'icon': Icons.home_rounded, 'route': 'home'},
    {'title': 'New Chat', 'description': 'Start a new AI conversation', 'icon': Icons.add_comment_rounded, 'route': 'new_chat'},
    {'title': 'Chat History', 'description': 'View your previous conversations', 'icon': Icons.history_rounded, 'route': 'chat_history'},
    {'title': 'Connect Website', 'description': 'Connect your website with HPC Smart AI', 'icon': Icons.language_rounded, 'route': 'connect_website'},
    {'title': 'Website Dashboard', 'description': 'View website analysis and reports', 'icon': Icons.dashboard_rounded, 'route': 'website_dashboard'},
    {'title': 'Website Scanner', 'description': 'Scan website pages and detect issues', 'icon': Icons.travel_explore_rounded, 'route': 'website_scanner'},
    {'title': 'AI Tools', 'description': 'Explore powerful AI tools', 'icon': Icons.auto_awesome_rounded, 'route': 'ai_tools'},
    {'title': 'My Projects', 'description': 'Manage your saved projects', 'icon': Icons.folder_rounded, 'route': 'my_projects'},
    {'title': 'CRM', 'description': 'Manage customers, leads and follow-ups', 'icon': Icons.people_alt_rounded, 'route': 'crm'},
    {'title': 'Notifications', 'description': 'View important updates and alerts', 'icon': Icons.notifications_rounded, 'route': 'notifications'},
    {'title': 'Help & Support', 'description': 'Get help and assistance', 'icon': Icons.support_agent_rounded, 'route': 'help_support'},
    {'title': 'Settings', 'description': 'Manage your app preferences', 'icon': Icons.settings_rounded, 'route': 'settings'},
    {'title': 'My Account', 'description': 'View and manage your account', 'icon': Icons.account_circle_rounded, 'route': 'my_account'},
    {'title': 'About HPC Smart AI', 'description': 'Learn more about HPC Smart AI', 'icon': Icons.info_rounded, 'route': 'about'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              color: blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.smart_toy_rounded, color: blue, size: 34),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'HPC Smart AI',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 3),
                  const Text('Your Personal AI Assistant', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in menuItems)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                      leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item['icon'] as IconData, color: blue, size: 21),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
                      ),
                      subtitle: Text(
                        item['description'] as String,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onNavigate(item['route'] as String);
                      },
                    ),
                  const Divider(height: 18),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                    leading: const Icon(Icons.logout_rounded, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Securely sign out of your account', style: TextStyle(fontSize: 11)),
                    onTap: () async {
                      Navigator.pop(context);
                      await onLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
