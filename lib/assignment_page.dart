import 'package:flutter/material.dart';

import 'api.dart' show Assignment;

class AssignmentPage extends StatelessWidget {
  final Assignment assignment;

  AssignmentPage({Key key, @required this.assignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backButton = Padding(
        child: Align(child: BackButton(), alignment: Alignment.centerLeft),
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0));

    final body = Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
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
