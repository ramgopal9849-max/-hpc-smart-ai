import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'AI Tools',
      description: 'Explore powerful AI tools',
      icon: Icons.auto_awesome_rounded,
    );
  }
}
