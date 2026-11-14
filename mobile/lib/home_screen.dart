import 'package:flutter/material.dart';

const Color hpcDashboardBlue = Color(0xFF2563EB);
const Color hpcDashboardDark = Color(0xFF172033);

class HomeScreen extends StatelessWidget {
  final String userName;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenDrawer;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.onOpenChat,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      (Icons.lightbulb_outline_rounded, 'Ask Anything', 'Get answers to your questions'),
      (Icons.language_rounded, 'Website Analysis', 'Understand your website'),
      (Icons.code_rounded, 'Coding Help', 'Get help with programming'),
      (Icons.auto_awesome_rounded, 'AI Assistant', 'Explore what AI can do'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: hpcDashboardDark),
            onPressed: onOpenDrawer,
          ),
        ),
        title: const Text(
          'HPC Smart AI',
          style: TextStyle(
            color: hpcDashboardDark,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onOpenChat,
            icon: const Icon(Icons.add_comment_outlined, color: hpcDashboardBlue),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 66,
                        width: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          size: 38,
                          color: hpcDashboardBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        'नमस्ते, $userName!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: hpcDashboardDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Center(
                      child: Text(
                        'आज मैं आपकी किस तरह मदद कर सकता हूँ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Explore HPC Smart AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: hpcDashboardDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suggestions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.28,
                      ),
                      itemBuilder: (context, index) {
                        final item = suggestions[index];
                        return InkWell(
                          onTap: onOpenChat,
                          borderRadius: BorderRadius.circular(17),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: const Color(0xFFE4E7EC)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item.$1, color: hpcDashboardBlue, size: 25),
                                const SizedBox(height: 12),
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: hpcDashboardDark,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.$3,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: InkWell(
                onTap: onOpenChat,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Message HPC Smart AI...',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: hpcDashboardBlue,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
