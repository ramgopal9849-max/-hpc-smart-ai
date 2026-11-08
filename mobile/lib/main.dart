import 'package:flutter/material.dart';

void main() {
  runApp(const HpcSmartAI());
}

class HpcSmartAI extends StatelessWidget {
  const HpcSmartAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPC Smart AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769E0),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  final messages = <String>[
    'नमस्ते! मैं HPC Smart AI हूँ। आपकी क्या सहायता कर सकता हूँ?',
  ];

  void sendMessage() {
    final message = controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add(message);
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1769E0),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HPC Smart AI'),
            Text(
              'Your Intelligent Assistant',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isUser = index > 0;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF1769E0)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'अपना सवाल लिखें...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
