import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class WebsiteScannerScreen extends StatelessWidget {
  const WebsiteScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Website Scanner',
      description: 'Scan website pages and detect issues',
      icon: Icons.travel_explore_rounded,
    );
  }
}
