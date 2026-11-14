import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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

// =====================================================
// API SERVICE
// =====================================================

class HpcApi {
  static const String baseUrl =
      'https://homeplumbercleaning.in/hpc-smart-ai-api';

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static String? token;
  static int? businessId;
  static Map<String, dynamic>? currentUser;

  static Future<void> loadSession() async {
    token = await storage.read(key: 'hpc_token');

    final savedBusinessId = await storage.read(key: 'hpc_business_id');

    businessId = int.tryParse(savedBusinessId ?? '');

    final userData = await storage.read(key: 'hpc_user');

    if (userData != null) {
      try {
        currentUser = Map<String, dynamic>.from(jsonDecode(userData));
      } catch (_) {
        currentUser = null;
      }
    }
  }

  static Map<String, String> _headers({bool authenticated = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      late http.Response response;

      if (method == 'POST') {
        response = await http.post(
          uri,
          headers: _headers(authenticated: authenticated),
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'GET') {
        response = await http.get(
          uri,
          headers: _headers(authenticated: authenticated),
        );
      } else {
        throw Exception('Unsupported request method.');
      }

      Map<String, dynamic> result;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          result = decoded;
        } else {
          throw Exception('Invalid server response.');
        }
      } catch (_) {
        throw Exception(
          'Server response samajh nahi aaya. HTTP ${response.statusCode}',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          result['success'] == false) {
        throw Exception(
          result['error'] ??
              result['message'] ??
              'Request failed. HTTP ${response.statusCode}',
        );
      }

      return result;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  static Future<void> saveSession(Map<String, dynamic> result) async {
    final newToken = result['token'];

    if (newToken == null || newToken.toString().isEmpty) {
      throw Exception('Server ne login token nahi diya.');
    }

    token = newToken.toString();

    await storage.write(key: 'hpc_token', value: token);

    final user = result['user'];

    if (user is Map) {
      currentUser = Map<String, dynamic>.from(user);

      await storage.write(key: 'hpc_user', value: jsonEncode(currentUser));
    }
  }

  static Future<void> logout() async {
    try {
      if (token != null) {
        await request('/auth/logout', method: 'POST', authenticated: true);
      }
    } catch (_) {}

    token = null;
    businessId = null;
    currentUser = null;

    await storage.delete(key: 'hpc_token');
    await storage.delete(key: 'hpc_user');
    await storage.delete(key: 'hpc_business_id');
  }

  static Future<List<Map<String, dynamic>>> getBusinesses() async {
    final result = await request('/businesses', authenticated: true);

    dynamic data = result['businesses'] ?? result['data'] ?? result['items'];

    if (data is Map) {
      data = data['businesses'] ?? data['items'];
    }

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<Map<String, dynamic>> getBusinessDashboard(int id) {
    return request('/dashboard/$id', authenticated: true);
  }

  static Future<Map<String, dynamic>> createBusiness({
    required String name,
    String websiteUrl = '',
  }) async {
    final body = <String, dynamic>{'name': name};

    if (websiteUrl.trim().isNotEmpty) {
      body['website_url'] = websiteUrl.trim();
    }

    return request(
      '/businesses',
      method: 'POST',
      body: body,
      authenticated: true,
    );
  }

  static Future<void> selectBusiness(int id) async {
    businessId = id;

    await storage.write(key: 'hpc_business_id', value: id.toString());
  }

  static Future<Map<String, dynamic>> getAIProvider(int id) {
    return request('/ai/provider/$id', authenticated: true);
  }

  static Future<Map<String, dynamic>> saveAIProvider({
    required int id,
    required String apiKey,
  }) {
    return request(
      '/ai/provider/$id',
      method: 'POST',
      authenticated: true,
      body: {
        'provider': 'openai',
        'model_name': 'gpt-4o-mini',
        'api_key': apiKey,
      },
    );
  }

  static Future<Map<String, dynamic>> sendAIMessage({
    required int id,
    required int chatId,
    required String message,
  }) {
    return request(
      '/ai/chat',
      method: 'POST',
      authenticated: true,
      body: {'business_id': id, 'chat_id': chatId, 'message': message},
    );
  }
}

// =====================================================
// COMMON HELPERS
// =====================================================

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
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

Widget pageButton(String label, VoidCallback? onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: hpcBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    ),
  );
}

void showPageMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

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
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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

// =====================================================
// HOME SCREEN - PART 1
// =====================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers
  final TextEditingController controller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  // Chat messages
  final List<Map<String, dynamic>> messages = [];

  // States
  bool sending = false;
  bool loadingSession = true;

  int chatId = 0;

  // =====================================================
  // PROFILE INITIALS
  // =====================================================

  String _getUserInitials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'U';

    return words.map((word) => word.characters.first.toUpperCase()).join();
  }

  // =====================================================
  // PROFILE AVATAR
  // =====================================================

  Widget _profileAvatar(String userName) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: hpcBlue,
      child: Text(
        _getUserInitials(userName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =====================================================
  // HOME FEATURES
  // =====================================================

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

  // =====================================================
  // INITIALIZE SESSION
  // =====================================================

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await HpcApi.loadSession();
    } catch (e) {
      debugPrint('Session loading error: $e');
    }

    if (mounted) {
      setState(() {
        loadingSession = false;
      });
    }
  }
  // =====================================================
  // SEND AI MESSAGE
  // =====================================================

  Future<void> sendMessage([String? suggestedMessage]) async {
    final message = (suggestedMessage ?? controller.text).trim();

    if (message.isEmpty || sending) return;

    // Login check
    if (HpcApi.token == null) {
      showPageMessage(context, 'AI Chat use karne ke liye pehle Login karein.');

      await openPage('Login / Register');
      return;
    }

    // Business connection check
    if (HpcApi.businessId == null) {
      showPageMessage(context, 'Pehle apna Business / Website connect karein.');

      await openPage('Connect Website');
      return;
    }

    setState(() {
      messages.add({'text': message, 'isUser': true});

      controller.clear();
      sending = true;
    });

    _scrollToBottom();

    try {
      final result = await HpcApi.sendAIMessage(
        id: HpcApi.businessId!,
        chatId: chatId,
        message: message,
      );

      final answer =
          result['answer']?.toString() ?? 'AI ne koi jawab nahi diya.';

      final returnedChatId = result['chat_id'];

      if (returnedChatId != null) {
        chatId = int.tryParse(returnedChatId.toString()) ?? chatId;
      }

      if (!mounted) return;

      setState(() {
        messages.add({'text': answer, 'isUser': false});
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'text': 'AI se jawab nahi mil saka.\n${e.toString()}',
          'isUser': false,
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });

        _scrollToBottom();
      }
    }
  }

  // =====================================================
  // SCROLL CHAT TO BOTTOM
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  // =====================================================
  // HOME SCREEN UI
  // =====================================================

  Widget _homeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // AI ICON
          Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome, size: 43, color: hpcBlue),
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
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),

          const SizedBox(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore what you can do',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),

          const SizedBox(height: 14),

          // FEATURE CARDS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

          Text(
            HpcApi.token == null
                ? 'Login karke apna AI workspace shuru karein.'
                : HpcApi.businessId == null
                ? 'AI use karne ke liye pehle website connect karein.'
                : 'What would you like help with today?',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
  // =====================================================
  // CHAT SCREEN
  // =====================================================

  Widget _chatScreen() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['isUser'] as bool;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 310),
            decoration: BoxDecoration(
              color: isUser ? hpcBlue : Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              message['text'] as String,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // MESSAGE INPUT
  // =====================================================

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
                onPressed: sending ? null : sendMessage,
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =====================================================
  // NEW CHAT
  // =====================================================

  void newChat() {
    setState(() {
      messages.clear();
      controller.clear();
      chatId = 0;
    });
  }

  // =====================================================
  // OPEN APP PAGES
  // =====================================================

  Future<void> openPage(String title) async {
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

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    if (mounted) {
      setState(() {});
    }
  }

  // =====================================================
  // PROFILE SCREEN
  // =====================================================

  Future<void> _openProfile() async {
    if (HpcApi.token == null) {
      await openPage('Login / Register');
      return;
    }

    if (!mounted) return;

    final user = HpcApi.currentUser ?? {};

    final userName = user['name']?.toString().trim().isNotEmpty == true
        ? user['name'].toString()
        : 'User';

    final email = user['email']?.toString() ?? '';

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 22),

                _profileAvatar(userName),

                const SizedBox(height: 12),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email.isEmpty ? 'Email not available' : email,
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Logged In',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);

                      await HpcApi.logout();

                      if (!mounted) return;

                      newChat();

                      setState(() {});
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // PROFILE ACTION
  // =====================================================

  Widget _profileAction() {
    if (HpcApi.token == null) {
      return TextButton(
        onPressed: () => openPage('Login / Register'),
        child: const Text(
          'Login / Register',
          style: TextStyle(
            color: hpcBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    final userName = HpcApi.currentUser?['name']?.toString() ?? 'User';

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: _openProfile,
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            Stack(
              children: [
                _profileAvatar(userName),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DRAWER MENU ITEM
  // =====================================================

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Icon(icon, color: hpcBlue, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.black54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {
        Navigator.pop(context);

        if (title == 'New Chat') {
          newChat();
        } else {
          openPage(title);
        }
      },
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // =====================================================
  // MAIN BUILD
  // =====================================================

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: hpcBlue,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'HPC Smart AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      HpcApi.currentUser?['name']?.toString() ??
                          'Your Intelligent Assistant',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              _menuItem(Icons.add, 'New Chat', 'Start a fresh conversation'),

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
                'View your conversations',
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

              if (HpcApi.token != null)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);

                    await HpcApi.logout();

                    if (!mounted) return;

                    newChat();

                    setState(() {});
                  },
                ),

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
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
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

          _profileAction(),
        ],
      ),

      body: loadingSession
          ? const Center(child: CircularProgressIndicator(color: hpcBlue))
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty ? _homeScreen() : _chatScreen(),
                ),

                if (sending)
                  const LinearProgressIndicator(minHeight: 2, color: hpcBlue),

                _messageInput(),
              ],
            ),
    );
  }
}
// =====================================================
// LOGIN / REGISTER
// =====================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool loading = false;

  final nameController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final identity = loginController.text.trim();
    final password = passwordController.text;

    if (!isLogin && nameController.text.trim().isEmpty) {
      showPageMessage(context, 'Full Name enter karein.');
      return;
    }

    if (identity.isEmpty || password.isEmpty) {
      showPageMessage(context, 'Email/mobile aur password enter karein.');
      return;
    }

    if (!isLogin && password.length < 10) {
      showPageMessage(
        context,
        'Registration password kam se kam 10 characters ka hona chahiye.',
      );
      return;
    }

    setState(() => loading = true);

    try {
      final isEmail = identity.contains('@');

      final Map<String, dynamic> body;

      if (isLogin) {
        body = {
          'login': identity,
          'password': password,
          'device_name': 'HPC Smart AI App',
        };
      } else {
        body = {
          'name': nameController.text.trim(),
          if (isEmail) 'email': identity,
          if (!isEmail) 'phone': identity,
          'password': password,
          'device_name': 'HPC Smart AI App',
        };
      }

      final result = await HpcApi.request(
        isLogin ? '/auth/login' : '/auth/register',
        method: 'POST',
        body: body,
      );

      await HpcApi.saveSession(result);

      if (!mounted) return;

      showPageMessage(
        context,
        isLogin ? 'Login successful.' : 'Registration successful.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showPageMessage(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: loginController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email or Mobile Number',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            pageButton(
              loading
                  ? 'Please wait...'
                  : isLogin
                  ? 'Login'
                  : 'Create Account',
              loading ? null : submit,
            ),
            const SizedBox(height: 15),
            pageNotice(
              'Public registration se customer account banega. '
              'Admin account public registration se nahi banaya ja sakta.',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// CONNECT WEBSITE / BUSINESS
// =====================================================

class ConnectWebsitePage extends StatefulWidget {
  const ConnectWebsitePage({super.key});

  @override
  State<ConnectWebsitePage> createState() => _ConnectWebsitePageState();
}

class _ConnectWebsitePageState extends State<ConnectWebsitePage> {
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  bool loading = false;
  List<Map<String, dynamic>> businesses = [];

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (!mounted) return;

    // Login ke baad businesses load karein.
    // Name aur URL controllers mein pehle se safe rahenge.
    if (HpcApi.token != null) {
      await loadBusinesses();
      if (mounted) setState(() {});
    }
  }

  Future<void> loadBusinesses() async {
    if (HpcApi.token == null) return;

    setState(() => loading = true);

    try {
      final list = await HpcApi.getBusinesses();

      if (!mounted) return;

      setState(() {
        businesses = list;
      });

      if (HpcApi.businessId == null && businesses.isNotEmpty) {
        final firstId = int.tryParse((businesses.first['id'] ?? '').toString());

        if (firstId != null) {
          await HpcApi.selectBusiness(firstId);
        }
      }
    } catch (e) {
      if (mounted) showPageMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> createBusiness() async {
    if (HpcApi.token == null) {
      showPageMessage(context, 'Pehle Login karein.');
      return;
    }

    final name = nameController.text.trim();
    final website = urlController.text.trim();

    if (name.isEmpty) {
      showPageMessage(context, 'Business name enter karein.');
      return;
    }

    if (website.isNotEmpty &&
        (!website.startsWith('https://') ||
            Uri.tryParse(website)?.host.isEmpty != false)) {
      showPageMessage(context, 'Website URL HTTPS se shuru hona chahiye.');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await HpcApi.createBusiness(
        name: name,
        websiteUrl: website,
      );

      dynamic business = result['business'] ?? result['data'];

      if (business is Map) {
        final id = int.tryParse((business['id'] ?? '').toString());

        if (id != null) {
          await HpcApi.selectBusiness(id);
        }
      }

      nameController.clear();
      urlController.clear();

      await loadBusinesses();

      if (mounted) {
        showPageMessage(
          context,
          result['message']?.toString() ??
              'Business connection request submitted.',
        );
      }
    } catch (e) {
      if (mounted) showPageMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> selectBusiness(Map<String, dynamic> item) async {
    final id = int.tryParse((item['id'] ?? '').toString());

    if (id == null) {
      showPageMessage(context, 'Business ID nahi mila.');
      return;
    }

    await HpcApi.selectBusiness(id);

    if (mounted) {
      setState(() {});
      showPageMessage(context, 'Business selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = HpcApi.token != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Website')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Connect Your Website',
              subtitle: 'Connect your business to HPC Smart AI',
              icon: Icons.language,
            ),

            const Text(
              'Business Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter business name',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Website URL (Optional)',
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

            const SizedBox(height: 18),

            pageButton(
              loading
                  ? 'Please wait...'
                  : isLoggedIn
                  ? 'Create / Connect Business'
                  : 'Login to Connect Website',
              loading
                  ? null
                  : isLoggedIn
                  ? createBusiness
                  : openLogin,
            ),

            if (!isLoggedIn) ...[
              const SizedBox(height: 12),
              pageNotice(
                'Pehle Business Name aur Website URL bharein. '
                'Connect karne ke liye Login zaroori hai. '
                'Login ke baad aapki bhari hui information bani rahegi.',
              ),
            ],

            if
