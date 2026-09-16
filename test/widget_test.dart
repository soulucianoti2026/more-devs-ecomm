import 'package:flutter_test/flutter_test.dart';

import 'package:more_devs_do_zero/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed.
    expect(find.text('+DevsEcomm'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
