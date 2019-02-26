import 'package:flutter/material.dart';

import 'api.dart' show Assignment;

class AssignmentPage extends StatelessWidget {
  final Assignment assignment;

  AssignmentPage({final Key key, @required final this.assignment})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final backButton = const Padding(
        child: const Align(
            child: const BackButton(), alignment: Alignment.centerLeft),
        padding: const EdgeInsets.only(top: 10.0, bottom: 0.0));

    final body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: const BoxDecoration(
          gradient: const LinearGradient(colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ]),
        ),
        child: Column(children: <Widget>[
          backButton,
        ]));

    return Scaffold(body: body);
  }
}
