import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';

class VChatTextMentionController extends TextEditingController {
  String _generatedRegexPattern = "()";
  final _pattern = '@';
  WordModel? _lastValidMentionWord;

  ///set debounce the delay between the emit of onSearch function
  final int debounce;

  /// add empty string after the mention
  final bool appendSpaceOnAdd;

  ///set style for the mention on the text filed value
  late TextStyle mentionStyle;

  final Map<String, MentionData> _annotationMapping = {};
  Timer? _debounce;

  TextEditingController get _controller => this;

  ///use this function to listen on the on new search detected
  ///if string is [null] then hide the list of the search
  ///if it has empty string "" this means the user just inserted @ you can show suggestions here
  ///other this will has the value without @
  Function(String?)? onSearch;

  VChatTextMentionController({
    this.debounce = 500,
    this.appendSpaceOnAdd = true,
    this.mentionStyle = const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w700,
    ),
  }) {
    addListener(_suggestionListener);
  }

  ///call this function to add new mention for the user
  void addMention(
    MentionData value,
  ) {
    _annotationMapping[_pattern + value.display] = value;
    _setPattern();
    _emitOnSearchChange(null, sendNow: true);
    final selectedMention = _lastValidMentionWord!;
    _lastValidMentionWord = null;
    _controller.text = _controller.value.text.replaceRange(
      selectedMention.wordStart,
      selectedMention.wordEnd,
      "$_pattern${value.display}${appendSpaceOnAdd ? ' ' : ''}",
    );
    int nextCursorPosition =
        selectedMention.wordStart + 1 + value.display.length;
    if (appendSpaceOnAdd) nextCursorPosition++;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: nextCursorPosition),
    );
  }

  void _suggestionListener() {
    final cursorIndex = _controller.selection.baseOffset;
    if (cursorIndex == -1) return;
    //parse all text from start 0 split all text to words and save all words in list with its start and end position!
    final textBeforeCursor = _controller.text.substring(0, cursorIndex);
    //get last message
    final lastWord = textBeforeCursor.split(" ").last;
    final lastWordModel = WordModel(
      word: lastWord,
      wordEnd: cursorIndex,
      wordStart: textBeforeCursor.lastIndexOf(lastWord),
    );
    if (lastWordModel.isStartWithAt) {
      _lastValidMentionWord = lastWordModel;
      _emitOnSearchChange(lastWord);
    } else {
      _emitOnSearchChange(null);
    }
  }

  @override
  TextSpan buildTextSpan({
    BuildContext? context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final children = <InlineSpan>[];
    if (_generatedRegexPattern == '()') {
      children.add(TextSpan(text: text, style: style));
    } else {
      text.splitMapJoin(
        //"(@hatem|@Ragap)"
        RegExp(_generatedRegexPattern),
        onMatch: (Match match) {
          if (_annotationMapping.isNotEmpty) {
            children.add(
              TextSpan(
                text: match[0],
                style: style!.merge(mentionStyle),
              ),
            );
          }
          return '';
        },
        onNonMatch: (String text) {
          children.add(TextSpan(text: text, style: style));
          return '';
        },
      );
    }
    return TextSpan(style: style, children: children);
  }

  @override
  void dispose() {
    removeListener(_suggestionListener);
    super.dispose();
  }

  ///get the text styled with [@${mention.display}:${mention.id}] which can be compiled by the [flutter_parsed_text] package
  /// Your pattern for ID & username extraction : `/\[(@[^:]+):([^\]]+)\]/`i
  String get markupText {
    if (_annotationMapping.isEmpty) {
      return text;
    }
    return text.splitMapJoin(
      //(@hatem|@Ragap)
      RegExp(_generatedRegexPattern),
      onMatch: (Match match) {
        final mention = _annotationMapping[match[0]!]!;
        // Default markup format for mentions
        return '[@${mention.display}:${mention.id}]';
      },
      onNonMatch: (String text) {
        return text;
      },
    );
  }

  void _setPattern() {
    /*
      {
          "@hatem":MentionData(),
          "@Ragap":MentionData()
      }
     */
    if (_annotationMapping.keys.isNotEmpty) {
      _generatedRegexPattern =
          "(${_annotationMapping.keys.map((key) => RegExp.escape(key)).join('|')})";
      // _pattern value will be = "(@hatem|@Ragap)"
    }
  }

  void _emitOnSearchChange(String? value, {bool sendNow = false}) {
    if (onSearch == null) return;
    if (_debounce != null && _debounce!.isActive) _debounce!.cancel();
    if (sendNow) {
      onSearch!.call(value);
      return;
    }
    _debounce = Timer(Duration(milliseconds: debounce), () {
      if (value == null) {
        //that means stop the search immorality
        onSearch!.call(null);
      } else if (value == "@") {
        //this means start search by @
        onSearch!.call("");
      } else {
        //this mean search by this value
        onSearch!.call(value.split(_pattern).last);
      }
    });
  }
}
