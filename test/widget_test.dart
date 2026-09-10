import 'package:flutter_test/flutter_test.dart';

import 'package:repostarce/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla de inicio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FuelFinderApp());

    expect(find.text('Usar mi ubicación actual'), findsOneWidget);
    expect(find.text('Buscar en esta provincia'), findsOneWidget);
  });
}
