import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamcoy/main.dart';

void main() {
  testWidgets('StreamcoyApp renders streamcoy shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StreamcoyApp()));

    // Verify Streamcoy title is present
    expect(find.text('Streamcoy'), findsWidgets);

    // Verify initial buttons and tabs exist
    expect(find.text('Start 30s Field Scan'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('AI Review'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
