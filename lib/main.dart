import 'package:flutter/material.dart'
    show
        BuildContext,
        Colors,
        MaterialApp,
        StatelessWidget,
        ThemeData,
        Widget,
        runApp;

import 'login_page.dart' show LoginPage;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'FCPS GradeView',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          fontFamily: 'Nunito',
        ),
        home: LoginPage(),
        initialRoute: LoginPage.tag,
      );
}
