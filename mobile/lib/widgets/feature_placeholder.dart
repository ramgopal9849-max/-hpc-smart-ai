import 'package:flutter/material.dart';

class FeaturePlaceholder extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 48, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'इस फीचर का अगला चरण अभी तैयार किया जा रहा है।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
