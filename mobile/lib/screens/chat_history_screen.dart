import 'package:flutter/material.dart';
import '../widgets/feature_placeholder.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Chat History',
      description: 'View your previous conversations',
      icon: Icons.history_rounded,
    );
  }
}
