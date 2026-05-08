import 'package:flutter_test/flutter_test.dart';

import 'package:reasoned/main.dart';

void main() {
  testWidgets('Onboarding-Screen zeigt Klarname-Eingabe', (tester) async {
    await tester.pumpWidget(const ReasonedApp());
    await tester.pump();
    expect(find.text('Willkommen bei Reasoned'), findsOneWidget);
    expect(find.text('Lege dein verifiziertes Profil an'), findsOneWidget);
  });
}
