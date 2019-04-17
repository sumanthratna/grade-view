import 'dart:io' show Platform;

import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart'
    show
        testWidgets,
        WidgetTester,
        Finder,
        find,
        expect,
        findsOneWidget,
        findsNothing;
import 'package:grade_view/main.dart' show MyApp;

void main() async {
  assert(Platform.environment['GVUSER'] != null &&
      Platform.environment['GVPASS'] != null);
  testWidgets('snackbar tests', (final WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    final Finder button = find.byKey(const Key('log-in')),
        username = find.byKey(const Key('username')),
        password = find.byKey(const Key('password'));

    await tester.tap(button);
    await tester.pump();
    expect(find.text('Please Enter a Username and Password'), findsOneWidget);

    await tester.enterText(username, Platform.environment['GVUSER']);
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Please Enter a Password'), findsOneWidget);

    await tester.enterText(password, Platform.environment['GVPASS']);
    await tester.tap(button);
    await tester.pump();
    expect(find.text(Platform.environment['GVUSER']), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Grades'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log In'), findsNothing);
  });
}
