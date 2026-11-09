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

// ---------------- HOME SCREEN ----------------

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

  void newChat() {
    setState(() {
      messages.clear();
      controller.clear();
    });
  }

  void openPage(String title) {
    Navigator.pop(context);

    Widget page;

    switch (title) {
      case 'Login / Register':
        page = const LoginPage();
        break;
      case 'Connect AI':
        page = const ConnectAIPage();
        break;
      case 'Connect Website':
        page = const ConnectWebsitePage();
        break;
      case 'Documents':
        page = const DocumentsPage();
        break;
      case 'Chat History':
        page = ChatHistoryPage(messages: messages);
        break;
      case 'Settings':
        page = const SettingsPage();
        break;
      case 'Help & Support':
        page = const HelpSupportPage();
        break;
      default:
        page = const PlaceholderPage(title: 'Coming Soon');
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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
                      radius: 29,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: hpcBlue,
                        size: 34,
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

              // MENU ITEMS WITH DESCRIPTIONS

              _menuItem(
                Icons.add,
                'New Chat',
                'Start a fresh conversation',
              ),
              _menuItem(
                Icons.login,
                'Login / Register',
                'Access or create your account',
              ),
              _menuItem(
                Icons.auto_awesome,
                'Connect AI',
                'Set up your AI provider',
              ),
              _menuItem(
                Icons.language,
                'Connect Website',
                'Connect your business website',
              ),
              _menuItem(
                Icons.folder_outlined,
                'Documents',
                'Upload and manage your files',
              ),
              _menuItem(
                Icons.history,
                'Chat History',
                'View your previous conversations',
              ),
              _menuItem(
                Icons.settings_outlined,
                'Settings',
                'Manage app preferences',
              ),
              _menuItem(
                Icons.help_outline,
                'Help & Support',
                'Get help and submit complaints',
              ),

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
            onPressed: newChat,
            icon: const Icon(Icons.edit_square, color: hpcBlue),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty ? _welcomeScreen() : _chatScreen(),
          ),
          _messageInput(),
        ],
      ),
    );
  }

  // MENU ITEM WIDGET WITH TITLE AND SUBTITLE

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 3,
      ),
      leading: Icon(
        icon,
        color: hpcBlue,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 20,
      ),
      onTap: () {
        if (title == 'New Chat') {
          Navigator.pop(context);
          newChat();
        } else {
          openPage(title);
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
                    border: Border.all(
                      color: const Color(0xFFE5EAF2),
                    ),
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
          border: Border(
            top: BorderSide(color: Color(0xFFE8ECF2)),
          ),
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
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- COMMON PAGE HEADER ----------------

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFFE8F0FF),
          child: Icon(icon, color: hpcBlue, size: 34),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

Widget pageNotice(String text) {
  return Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF1FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: hpcBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Widget pageButton(String label, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: hpcBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    ),
  );
}

void showPageMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// ---------------- LOGIN / REGISTER ----------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const PageHeader(
              title: 'Welcome to HPC Smart AI',
              subtitle: 'Access your personal AI workspace',
              icon: Icons.person_outline,
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Login')),
                ButtonSegment(value: false, label: Text('Register')),
              ],
              selected: {isLogin},
              onSelectionChanged: (value) {
                setState(() => isLogin = value.first);
              },
            ),
            const SizedBox(height: 22),
            if (!isLogin) ...[
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
            ],
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email or Mobile Number',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            pageButton(
              isLogin ? 'Login' : 'Create Account',
              () => showPageMessage(
                context,
                'Account service backend abhi connect nahi hua hai.',
              ),
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Login aur registration ka interface taiyar hai. '
              'Account banane aur login karne ke liye backend '
              'integration agle phase mein hogi.',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- CONNECT AI ----------------

class ConnectAIPage extends StatefulWidget {
  const ConnectAIPage({super.key});

  @override
  State<ConnectAIPage> createState() => _ConnectAIPageState();
}

class _ConnectAIPageState extends State<ConnectAIPage> {
  String provider = 'OpenAI';
  final keyController = TextEditingController();

  @override
  void dispose() {
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Connect Your AI',
              subtitle: 'Choose an AI provider for your workspace',
              icon: Icons.auto_awesome,
            ),
            const Text(
              'AI Provider',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: provider,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'OpenAI',
                  child: Text('OpenAI'),
                ),
                DropdownMenuItem(
                  value: 'Google Gemini',
                  child: Text('Google Gemini'),
                ),
                DropdownMenuItem(
                  value: 'Other Provider',
                  child: Text('Other Provider'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => provider = value);
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'API Key',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter API key',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            pageButton(
              'Connect AI',
              () => showPageMessage(
                context,
                'AI connection backend abhi taiyar nahi hai. '
                'API key abhi save ya send nahi ki gayi.',
              ),
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Yeh abhi setup screen hai. API key ko is version mein '
              'save ya kisi server par send nahi kiya jayega.',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- CONNECT WEBSITE ----------------

class ConnectWebsitePage extends StatefulWidget {
  const ConnectWebsitePage({super.key});

  @override
  State<ConnectWebsitePage> createState() => _ConnectWebsitePageState();
}

class _ConnectWebsitePageState extends State<ConnectWebsitePage> {
  final urlController = TextEditingController();

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Website')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Connect Your Website',
              subtitle: 'Bring your business information into HPC Smart AI',
              icon: Icons.language,
            ),
            const Text(
              'Website URL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            pageButton(
              'Connect Website',
              () {
                if (urlController.text.trim().isEmpty) {
                  showPageMessage(context, 'Website URL enter karein.');
                  return;
                }
                showPageMessage(
                  context,
                  'Website connection backend abhi connect nahi hai.',
                );
              },
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Website connect hone ke baad AI ko authorized website '
              'ki information read karne ki permission di ja sakegi. '
              'Is screen se abhi koi website access nahi hoti.',
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.shield_outlined, color: hpcBlue),
              title: Text('Secure Business Connection'),
              subtitle: Text('Website authorization will be required.'),
            ),
            const ListTile(
              leading: Icon(Icons.visibility_outlined, color: hpcBlue),
              title: Text('Read-only Website Access'),
              subtitle: Text('Website data ko bina approval badla nahi jayega.'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- DOCUMENTS ----------------

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Your Documents',
              subtitle: 'Upload and understand your files',
              icon: Icons.folder_open_outlined,
            ),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 55,
                    color: hpcBlue,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Upload Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'PDF, DOCX, TXT and other supported files',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            pageButton(
              'Choose Document',
              () => showPageMessage(
                context,
                'Document upload feature agle phase mein connect hogi.',
              ),
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Abhi file upload aur document analysis backend available '
              'nahi hai. Yeh screen uske liye taiyar ki gayi hai.',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- CHAT HISTORY ----------------

class ChatHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const ChatHistoryPage({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat History')),
      body: messages.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 60,
                      color: hpcBlue,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No Chat History Yet',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Your current chat messages will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F0FF),
                      child: Icon(Icons.chat, color: hpcBlue),
                    ),
                    title: Text(message['text'] as String),
                    subtitle: Text(
                      message['isUser'] == true
                          ? 'You'
                          : 'HPC Smart AI',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------- SETTINGS ----------------

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String language = 'English';
  String theme = 'Light';
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Manage your app preferences',
            icon: Icons.settings_outlined,
          ),
          const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: language,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'English',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'Hindi',
                child: Text('Hindi'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => language = value);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: theme,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Light', child: Text('Light')),
              DropdownMenuItem(value: 'Dark', child: Text('Dark')),
              DropdownMenuItem(value: 'System', child: Text('System Default')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => theme = value);
            },
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preference'),
            secondary: const Icon(Icons.notifications_outlined),
            value: notifications,
            activeColor: hpcBlue,
            onChanged: (value) {
              setState(() => notifications = value);
            },
          ),
          const SizedBox(height: 15),
          pageNotice(
            'Settings abhi isi screen par temporary hain. '
            'Language, theme aur notifications ki permanent saving '
            'baad mein add hogi.',
          ),
        ],
      ),
    );
  }
}

// ---------------- HELP & SUPPORT ----------------

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PageHeader(
            title: 'How Can We Help?',
            subtitle: 'Get help with HPC Smart AI',
            icon: Icons.support_agent,
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.question_answer_outlined,
                color: hpcBlue,
              ),
              title: const Text('Frequently Asked Questions'),
              subtitle: const Text('Find answers to common questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPageMessage(
                context,
                'FAQ section agle phase mein add hoga.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.mail_outline,
                color: hpcBlue,
              ),
              title: const Text('Contact Support'),
              subtitle: const Text('Get assistance from our support team'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPageMessage(
                context,
                'Support contact system abhi connect nahi hai.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.report_problem_outlined,
                color: hpcBlue,
              ),
              title: const Text('Submit a Complaint'),
              subtitle: const Text('Report a problem or issue'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ComplaintPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          pageNotice(
            'Support aur complaint options ka interface taiyar hai. '
            'Messages bhejne ke liye backend baad mein connect hoga.',
          ),
        ],
      ),
    );
  }
}

// ---------------- COMPLAINT PAGE ----------------

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Tell Us Your Problem',
              subtitle: 'Describe the issue you are facing',
              icon: Icons.report_problem_outlined,
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Complaint Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Describe your complaint',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            pageButton(
              'Submit Complaint',
              () => showPageMessage(
                context,
                'Complaint submission backend abhi connect nahi hai.',
              ),
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Is version mein complaint submit nahi hogi. '
              'Complaint system backend integration ke baad kaam karega.',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PLACEHOLDER ----------------

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('Coming Soon'),
      ),
    );
  }
}
