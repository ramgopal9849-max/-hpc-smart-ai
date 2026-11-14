import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'About HPC Smart AI',
      description: 'Learn more about HPC Smart AI',
      icon: Icons.info_rounded,
    );
  }
}
