import 'package:flutter_test/flutter_test.dart';

import 'package:malama_zainab_muhadara2/main.dart';

void main() {
  testWidgets('App boots and shows the scholar header', (tester) async {
    await tester.pumpWidget(const IslamicAudioApp());

    expect(
      find.text('Malama Zainab Jaafar'),
      findsOneWidget,
    );
  });
}
