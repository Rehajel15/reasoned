import 'package:flutter_test/flutter_test.dart';

import 'package:reasoned/main.dart';

void main() {
  testWidgets('Onboarding-Screen zeigt Ausweis-Capture', (tester) async {
    await tester.pumpWidget(const ReasonedApp());
    await tester.pump();
    expect(find.text('Willkommen bei Reasoned'), findsOneWidget);
    expect(
      find.text('Verifiziere dich mit deinem Personalausweis'),
      findsOneWidget,
    );
  });
}
