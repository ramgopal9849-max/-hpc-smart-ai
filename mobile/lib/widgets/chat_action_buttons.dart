import 'package:flutter/material.dart';

class ChatActionButtons extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final ValueChanged<String> onSelected;

  const ChatActionButtons({
    super.key,
    required this.actions,
    required this.onSelected,
  });

  Color _buttonColor(String style) {
    switch (style.toLowerCase()) {
      case 'green':
        return const Color(0xFF14532D);
      case 'red':
        return const Color(0xFF7F1D1D);
      case 'blue':
        return const Color(0xFF1E3A8A);
      default:
        return const Color(0xFF252B36);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions.map((action) {
            final label = action['label']?.toString() ?? '';
            final value = action['value']?.toString() ?? label;
            final style = action['style']?.toString() ?? 'dark';

            if (label.trim().isEmpty || value.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return ElevatedButton(
              onPressed: () => onSelected(value),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor(style),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
