import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamcoy/main.dart';

void main() {
  testWidgets('EchoStreamApp renders sentinel shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EchoStreamApp()));

    // Verify Sentinel title is present
    expect(find.text('EchoStream Sentinel'), findsOneWidget);

    // Verify initial buttons and tabs exist
    expect(find.text('Start 30s Field Scan'), findsOneWidget);
    expect(find.text('Field Scan'), findsOneWidget);
    expect(find.text('Explainable AI'), findsOneWidget);
    expect(find.text('One Health'), findsOneWidget);
  });
}
