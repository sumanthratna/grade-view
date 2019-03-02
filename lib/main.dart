import 'package:flutter/material.dart';
import 'login_page.dart' show LoginPage;
import 'home_page.dart' show HomePage;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (final context) => LoginPage(),
    HomePage.tag: (final context) => HomePage(),
  };

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Kodeversitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}
