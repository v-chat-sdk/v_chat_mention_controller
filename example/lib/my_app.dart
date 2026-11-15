import 'package:flutter/material.dart';

import 'my_home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage(title: 'Flutter Demo Home Page'));
  }
}
