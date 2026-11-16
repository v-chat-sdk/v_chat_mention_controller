import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('selects a mention and sends its markup', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextField), '@user');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('user 0').first);
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(
      tester.widget<ParsedText>(find.byType(ParsedText)).text,
      '[@user 0:id-user 0] ',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
