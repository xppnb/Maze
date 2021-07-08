import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_home.dart';

void main() {
  SystemUiOverlayStyle systemUiOverlayStyle =
      new SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameHome(),
    );
  }
}
