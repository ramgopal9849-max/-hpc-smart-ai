import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class ConnectWebsiteScreen extends StatelessWidget {
  const ConnectWebsiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Connect Website',
      description: 'Connect your business website with HPC Smart AI',
      icon: Icons.language_rounded,
    );
  }
}
