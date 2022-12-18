class WordModel {
  WordModel({
    required this.wordStart,
    required this.wordEnd,
    required this.word,
  });

  String word;
  int wordStart;
  int wordEnd;
  bool get isStartWithAt => word.startsWith("@");
  @override
  String toString() {
    return '{word: $word, start: $wordStart, end: $wordEnd}';
  }
}

class MentionData {
  ///id for the user which you will use it to navigate to user page if mention clicked
  final String id;

  ///user name
  final String display;

  MentionData({
    required this.id,
    required this.display,
  });
}
