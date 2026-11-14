import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Notifications',
      description: 'View important updates and alerts',
      icon: Icons.notifications_rounded,
    );
  }
}
