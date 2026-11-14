import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class WebsiteDashboardScreen extends StatelessWidget {
  const WebsiteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Website Dashboard',
      description: 'View website analysis and reports',
      icon: Icons.dashboard_rounded,
    );
  }
}
