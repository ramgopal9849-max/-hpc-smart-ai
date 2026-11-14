import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Help & Support',
      description: 'Get help and assistance',
      icon: Icons.support_agent_rounded,
    );
  }
}
