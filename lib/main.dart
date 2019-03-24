import 'package:flutter/material.dart';
import 'login_page.dart' show LoginPage;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

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
      initialRoute: LoginPage.tag,
    );
  }
}
