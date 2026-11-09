
import 'package:flutter/material.dart';

void main() {
  runApp(const HpcSmartAI());
}

const Color hpcBlue = Color(0xFF1769E0);
const Color hpcBackground = Color(0xFFF7F9FC);

class HpcSmartAI extends StatelessWidget {
  const HpcSmartAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPC Smart AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: hpcBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: hpcBlue),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Ask Anything',
      'subtitle': 'Ask questions and get answers',
      'icon': Icons.chat_bubble_outline,
      'prompt': 'Hello HPC Smart AI!',
    },
    {
      'title': 'Business Help',
      'subtitle': 'Grow and manage your business',
      'icon': Icons.business_center_outlined,
      'prompt': 'Help me with my business.',
    },
    {
      'title': 'Code Analysis',
      'subtitle': 'Review and audit your code',
      'icon': Icons.code,
      'prompt': 'I want to analyze my code.',
    },
    {
      'title': 'Documents',
      'subtitle': 'Understand your documents',
      'icon': Icons.description_outlined,
      'prompt': 'I want help with a document.',
    },
  ];

  void sendMessage([String? suggestedMessage]) {
    final message = (suggestedMessage ?? controller.text).trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add({
        'text': message,
        'isUser': true,
      });

      controller.clear();
    });

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void newChat() {
    setState(() {
      messages.clear();
      controller.clear();
    });
  }

  void showMenuMessage(String title) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title सुविधा अगले चरण में तैयार होगी।'),
      ),
    );
  }

  Widget featureCard(Map<String, dynamic> feature) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => sendMessage(feature['prompt'] as String),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7ECF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              feature['icon'] as IconData,
              color: hpcBlue,
              size: 27,
            ),
            const SizedBox(height: 13),
            Text(
              feature['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              feature['subtitle'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageBubble(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] as bool;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: isUser ? hpcBlue : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isUser
              ? null
              : Border.all(color: const Color(0xFFE7ECF3)),
        ),
        child: Text(
          message['text'] as String,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMessages = messages.isNotEmpty;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: hpcBlue,
                      child: Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'HPC Smart AI',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add, color: hpcBlue),
                title: const Text('New Chat'),
                onTap: () {
                  newChat();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Chat History'),
                onTap: () => showMenuMessage('Chat History'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 5),
                child: Text(
                  'ACCOUNT & TOOLS',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login / Register'),
                onTap: () => showMenuMessage('Login / Register'),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Connect Website'),
                onTap: () => showMenuMessage('Connect Website'),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Connect AI'),
                onTap: () => showMenuMessage('Connect AI'),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Documents'),
                onTap: () => showMenuMessage('Documents'),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () => showMenuMessage('Settings'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () => showMenuMessage('Help & Support'),
              ),
              const Spacer(),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Smarter Business. Bigger Growth.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: hpcBlue, size: 25),
            SizedBox(width: 9),
            Text(
              'HPC Smart AI',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New Chat',
            onPressed: newChat,
            icon: const Icon(Icons.edit_square, color: hpcBlue),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: hasMessages
                  ? ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messageBubble(messages[index]);
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 38, 18, 20),
                      child: Column(
                        children: [
                          Container(
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.smart_toy_outlined,
                              color: hpcBlue,
                              size: 43,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'नमस्ते! मैं HPC Smart AI हूँ।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'आज मैं आपकी किस काम में मदद कर सकता हूँ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 32),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: features.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.22,
                            ),
                            itemBuilder: (context, index) {
                              return featureCard(features[index]);
                            },
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Your intelligent assistant',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFFE1E7EF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => sendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Message HPC Smart AI...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black45),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: sendMessage,
                          style: IconButton.styleFrom(
                            backgroundColor: hpcBlue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'HPC Smart AI can make mistakes. Check important information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
