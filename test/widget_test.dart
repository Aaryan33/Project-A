import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umiya_pnj_orders/main.dart';

void main() {
  testWidgets('App renders test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UmiyaPnjApp()));
    expect(find.byType(UmiyaPnjApp), findsOneWidget);
  });
}
