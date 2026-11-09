
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
      'prompt': 'Hello HPC Smart AI, help me.',
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

  void showMenuMessage(String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: यह सुविधा अगले चरण में जोड़ी जाएगी।')),
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
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                color: hpcBlue,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: hpcBlue,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'HPC Smart AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your Intelligent Assistant',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _menuItem(Icons.add, 'New Chat'),
              _menuItem(Icons.login, 'Login / Register'),
              _menuItem(Icons.auto_awesome, 'Connect AI'),
              _menuItem(Icons.language, 'Connect Website'),
              _menuItem(Icons.folder_outlined, 'Documents'),
              _menuItem(Icons.history, 'Chat History'),
              _menuItem(Icons.settings_outlined, 'Settings'),
              _menuItem(Icons.help_outline, 'Help & Support'),
              const Spacer(),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'HPC Smart AI • Version 1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
            CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFEAF1FF),
              child: Icon(Icons.smart_toy_outlined, color: hpcBlue),
            ),
            SizedBox(width: 10),
            Text(
              'HPC Smart AI',
              style: TextStyle(
                color: Color(0xFF17243A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New Chat',
            onPressed: () => setState(() => messages.clear()),
            icon: const Icon(Icons.edit_square, color: hpcBlue),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _welcomeScreen()
                : _chatScreen(),
          ),
          _messageInput(),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: hpcBlue),
      title: Text(title),
      onTap: () {
        if (title == 'New Chat') {
          Navigator.pop(context);
          setState(() => messages.clear());
        } else {
          showMenuMessage(title);
        }
      },
    );
  }

  Widget _welcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 43,
              color: hpcBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hello! Welcome to',
            style: TextStyle(fontSize: 19, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          const Text(
            'HPC Smart AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: Color(0xFF17243A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your intelligent assistant for questions, business, '
            'documents and technology.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore what you can do',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => sendMessage(feature['prompt'] as String),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        color: hpcBlue,
                        size: 27,
                      ),
                      const Spacer(),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        feature['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'What would you like help with today?',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _chatScreen() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['isUser'] as bool;

        return Align(
          alignment:
              isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: isUser ? hpcBlue : Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              message['text'] as String,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8ECF2))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Message HPC Smart AI...',
                  filled: true,
                  fillColor: hpcBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            CircleAvatar(
              radius: 24,
              backgroundColor: hpcBlue,
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
