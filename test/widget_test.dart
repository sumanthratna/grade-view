import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grade_view/main.dart' show MyApp;
import 'package:grade_view/api.dart' show API, User, Course;

import 'dart:io' show Platform;

import 'dart:convert' show jsonDecode;

void main() async {
  assert(Platform.environment['USER']!=null && Platform.environment['PASS']!=null);
  User test = User.fromJson(jsonDecode((await API.getUser(
          Platform.environment['USER'], Platform.environment['PASS']))
      .body));
  final courses = jsonDecode(
      (await API.getGrades(test.username, Platform.environment['PASS']))
          .body)['courses'];
  test.courses = [];
  courses.forEach((final f) => test.courses.add(Course.fromJson(f as Map<String, dynamic>)));

  testWidgets('snackbar tests', (final WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    final Finder button = find.byKey(const Key('log-in')),
        username = find.byKey(const Key('username')),
        password = find.byKey(const Key('password'));

    await tester.tap(button);
    await tester.pump();
    expect(find.text('Please Enter a Username and Password'), findsOneWidget);

    await tester.enterText(username, test.username);
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Please Enter a Password'), findsOneWidget);

    await tester.enterText(password, Platform.environment['PASS']);
    await tester.tap(button);
    await tester.pump();
    expect(find.text(test.username), findsOneWidget); //logged in
  });
}
