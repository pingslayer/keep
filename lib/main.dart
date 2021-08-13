import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './views/home_view.dart';
import './views/transactions_view.dart';

void main() => runApp(MyApp());

final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: nav,
      theme: ThemeData(
        backgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          color: Colors.grey[800],
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 82.0, fontWeight: FontWeight.w100, color: Colors.white),
          bodyText2: TextStyle(fontSize: 52.0, fontWeight: FontWeight.w100, color: Colors.white),
          headline3: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w100, color: Colors.white),
          headline4: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w100, color: Colors.white),
          headline5: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w100, color: Colors.white),
          button: TextStyle(fontSize: 16.0, color: Colors.grey[900]),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
        '/transactions': (context) => Transactions(),
      }
    );
  }

}