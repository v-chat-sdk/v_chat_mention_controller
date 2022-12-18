import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:v_chat_mention_controller/v_chat_mention_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final controller = VChatTextMentionController(
    debounce: 500,

    ///set custom style
    mentionStyle: const TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.w800,
    ),
  );

  String parsedText = "";
  final logs = <String>[];
  final _fakeUsersDataServer = List.generate(100, (index) => "user $index");
  final users = <String>[];
  bool _isSearchCanView = false;

  @override
  void initState() {
    super.initState();
    // controller.addMention(Mention(id: "id", name: "name"));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => ListTile(
                  title: ParsedText(
                    text: logs[index],
                    style: const TextStyle(color: Colors.black87),
                    parse: <MatchText>[
                      MatchText(
                        pattern: r"\[(@[^:]+):([^\]]+)\]",
                        style: const TextStyle(
                          color: Colors.indigo,
                        ),
                        renderWidget: ({required pattern, required text}) {
                          return Text(text);
                        },
                        // you must return a map with two keys
                        // [display] - the text you want to show to the user
                        // [value] - the value underneath it
                        renderText: (
                            {required String str, required String pattern}) {
                          final map = <String, String>{};
                          final RegExp customRegExp =
                              RegExp(r"\[(@[^:]+):([^\]]+)\]");
                          final match = customRegExp.firstMatch(str);
                          map['display'] = match!.group(1)!;
                          return map;
                        },
                        onTap: (url) {
                          final customRegExp = RegExp(r"\[(@[^:]+):([^\]]+)\]");
                          final match = customRegExp.firstMatch(url)!;
                          final snackBar = SnackBar(
                            content: Text(
                                'id is ${match.group(2)} name is ${match.group(1)}'),
                            duration: const Duration(seconds: 7),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                      ),
                    ],
                  ),
                ),
                itemCount: logs.length,
              ),
            ),
            Column(
              children: [
                Visibility(
                  visible: _isSearchCanView,
                  child: SizedBox(
                    height: 200,
                    child: ListView(
                      shrinkWrap: true,
                      children: users
                          .map(
                            (e) => ListTile(
                              onTap: () {
                                controller.addMention(
                                  MentionData(
                                    id: "id-$e",
                                    display: e,
                                  ),
                                );
                              },
                              title: Text(e),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          logs.add(controller.markupText);
                          controller.clear();
                        });
                      },
                      child: const Text("Send"),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
