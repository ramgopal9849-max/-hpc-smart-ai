import 'package:flutter_test/flutter_test.dart';
import 'package:hpc_smart_ai/main.dart';

void main() {
  testWidgets('HPC Smart AI app launches successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HpcSmartAI());

    await tester.pump();

    expect(find.byType(HpcSmartAI), findsOneWidget);
  });
}
