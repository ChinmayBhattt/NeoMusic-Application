import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/storage_service.dart';

void main() {
  testWidgets('NeoMusic app smoke test renders main shell', (WidgetTester tester) async {
    // Mock shared preferences
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();

    await tester.pumpWidget(
      const ProviderScope(
        child: NeoMusicApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify presence of core navigation items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
