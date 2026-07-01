import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/main.dart';

void main() {
  testWidgets('FeelView app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FeelViewApp()));
    expect(find.text('FeelView'), findsWidgets);
  });
}
