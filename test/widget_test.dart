import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hexa_shift/main.dart';

void main() {
  // Disable Google Fonts runtime HTTP fetching during tests
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize SharedPreferences with empty mock values for testing
  SharedPreferences.setMockInitialValues({});

  testWidgets('App title display smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HexaShiftApp(),
      ),
    );

    // Wait for all microtasks, futures, and animations to complete
    await tester.pumpAndSettle();

    // Verify that the title "HEXA SHIFT" is rendered on the screen.
    expect(find.text('HEXA SHIFT'), findsWidgets);
  });
}
