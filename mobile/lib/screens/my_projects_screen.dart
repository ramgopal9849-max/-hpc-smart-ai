import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'My Projects',
      description: 'Manage your saved projects',
      icon: Icons.folder_rounded,
    );
  }
}
