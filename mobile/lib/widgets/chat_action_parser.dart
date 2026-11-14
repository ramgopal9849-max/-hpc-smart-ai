import 'dart:convert';

class ParsedChatResponse {
  final String text;
  final List<Map<String, dynamic>> actions;

  const ParsedChatResponse({
    required this.text,
    required this.actions,
  });
}

class ChatActionParser {
  static ParsedChatResponse parse(String response) {
    const start = '[[HPC_ACTIONS]]';
    const end = '[[/HPC_ACTIONS]]';

    final startIndex = response.indexOf(start);
    final endIndex = response.indexOf(end);

    if (startIndex == -1 || endIndex == -1 || endIndex < startIndex) {
      return ParsedChatResponse(
        text: response.trim(),
        actions: const [],
      );
    }

    final jsonText = response.substring(
      startIndex + start.length,
      endIndex,
    ).trim();

    final visibleText = (
      response.substring(0, startIndex) +
      response.substring(endIndex + end.length)
    ).trim();

    try {
      final decoded = jsonDecode(jsonText);

      if (decoded is! List) {
        return ParsedChatResponse(
          text: visibleText,
          actions: const [],
        );
      }

      final actions = <Map<String, dynamic>>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final label = item['label']?.toString().trim() ?? '';
        final value = item['value']?.toString().trim() ?? '';
        final rawStyle = item['style']?.toString().toLowerCase() ?? 'dark';

        if (label.isEmpty || value.isEmpty) continue;

        actions.add({
          'label': label,
          'value': value,
          'style': ['dark', 'blue', 'green', 'red'].contains(rawStyle)
              ? rawStyle
              : 'dark',
        });
      }

      return ParsedChatResponse(
        text: visibleText,
        actions: actions,
      );
    } catch (_) {
      return ParsedChatResponse(
        text: visibleText,
        actions: const [],
      );
    }
  }
}
