import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_chat_mention_controller/v_chat_mention_controller.dart';

void main() {
  for (final separator in [' ', '\n', '\t']) {
    testWidgets(
      'restores and inserts a mention after whitespace ${separator.codeUnits}',
      (tester) async {
        final searches = <String?>[];
        final controller = VChatTextMentionController()
          ..onSearch = searches.add;
        addTearDown(controller.dispose);
        final draft = 'Hello$separator@al';
        controller.value = TextEditingValue(
          text: draft,
          selection: TextSelection.collapsed(offset: draft.length),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(searches.last, 'al');
        controller.addMention(MentionData(id: 'alice', display: 'Alice'));
        expect(controller.text, 'Hello$separator@Alice ');
        expect(controller.markupText, 'Hello$separator[@Alice:alice] ');
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  }

  testWidgets('adds a mention and preserves markup and cursor', (tester) async {
    final controller = VChatTextMentionController();
    addTearDown(controller.dispose);
    controller.value = const TextEditingValue(
      text: 'Hello @al',
      selection: TextSelection.collapsed(offset: 9),
    );
    controller.addMention(MentionData(id: 'alice', display: 'Alice'));
    expect(controller.text, 'Hello @Alice ');
    expect(controller.markupText, 'Hello [@Alice:alice] ');
    expect(controller.selection.baseOffset, controller.text.length);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('renders a mention when the base style is null', (tester) async {
    final controller = VChatTextMentionController();
    addTearDown(controller.dispose);
    controller.value = const TextEditingValue(
      text: '@al',
      selection: TextSelection.collapsed(offset: 3),
    );
    controller.addMention(MentionData(id: 'alice', display: 'Alice'));
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          final span = controller.buildTextSpan(
            context: context,
            withComposing: false,
          );
          expect(span.toPlainText(), '@Alice ');
          return const SizedBox();
        },
      ),
    );
  });

  testWidgets('cancels pending searches when disposed', (tester) async {
    final searches = <String?>[];
    final controller = VChatTextMentionController()..onSearch = searches.add;
    controller.value = const TextEditingValue(
      text: '@alice',
      selection: TextSelection.collapsed(offset: 6),
    );
    controller.dispose();
    expect(controller.onSearch, isNull);
    await tester.pump(const Duration(seconds: 1));
    expect(searches, isEmpty);
  });

  testWidgets('allows clearing the callback while a search is pending', (
    tester,
  ) async {
    final controller = VChatTextMentionController()..onSearch = (_) {};
    addTearDown(controller.dispose);
    controller.value = const TextEditingValue(
      text: '@alice',
      selection: TextSelection.collapsed(offset: 6),
    );
    controller.onSearch = null;
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
