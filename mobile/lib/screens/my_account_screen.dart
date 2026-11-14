import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'My Account',
      description: 'View and manage your account',
      icon: Icons.account_circle_rounded,
    );
  }
}
