- use this package to detect mentions in text filed
- '@'
- support all language
- support custom widgets
- only you need to create the controller in your state

```dart

final controller = VChatTextMentionController(
  debounce: 500,

  ///set custom style
  mentionStyle: const TextStyle(
    color: Colors.deepPurple,
    fontWeight: FontWeight.w800,
  ),
);
```

- make sure to call dispose after exit from the screen!
- Listen to on search detect

```dart
  @override
void initState() {
  super.initState();
  controller.onSearch = (str) async {
    users.clear();
    if (str != null) {
      //  print("search by $str");
      _isSearchCanView = true;
      if (str.isEmpty) {
        users.addAll(_fakeUsersDataServer);
      }
      //send request
      for (var element in _fakeUsersDataServer) {
        if (element.startsWith(str)) {
          users.add(element);
        }
      }
    } else {
      //stop request
      _isSearchCanView = false;
    }
    setState(() {});
  };
}

```

- once you want to add new mention just call

``` 
  controller.addMention(
        MentionData(
          id: "User id",
          display: "USER NAME",
        ),
      );
```

- once you want to get the data as makeup text call

```dart
controller.markupText
```

- you need to use https://pub.dev/packages/flutter_parsed_text
- to parse and view the mention text see the example in the package for how to use it !
