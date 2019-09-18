import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, TargetPlatform;

import 'dart:io' show Platform;

import 'package:flutter/material.dart'
    show
        BuildContext,
        Colors,
        MaterialApp,
        StatelessWidget,
        ThemeData,
        Widget,
        runApp;

import 'package:grade_view/ui.dart' show LoginPage;

void main() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
  runApp(MyApp());
}

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
