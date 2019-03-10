import 'package:flutter/material.dart';

import 'api.dart' show Course, Assignment;

class AssignmentPage extends StatelessWidget {
  final Course course;
  final Assignment assignment;

  AssignmentPage(
      {final Key key,
      @required final this.course,
      @required final this.assignment})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final backButton = const Padding(
        child: const Align(
            child: const BackButton(color: Colors.white),
            alignment: Alignment.centerLeft),
        padding: const EdgeInsets.only(top: 10.0, bottom: 0.0));

    final assignmentInfo = ListView(children: <Widget>[
      Info(
          left: "Score",
          right: assignment.achievedScore.toString() +
              "/" +
              assignment.maxScore.toString()),
      Info(left: "Type", right: assignment.assignmentType),
      Info(left: "Teacher", right: course.teacher),
      Info(left: "Period", right: course.period.toString()),
      Info(left: "Date", right: _formatDate(assignment.date)),
      Info(left: "Due Date", right: _formatDate(assignment.dueDate))
    ]);
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
          Center(
              child: Text(assignment.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32.0, color: Colors.white))),
          Expanded(child: assignmentInfo)
        ]));

    return Scaffold(body: body);
  }

  String _formatDate(DateTime arg) {
    return arg.month.toString() +
        "/" +
        arg.day.toString() +
        "/" +
        arg.year.toString();
  }
}

class Info extends StatelessWidget {
  final String left, right;
  Info({Key key, @required this.left, @required this.right}) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () {},
            child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Text(left,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                              maxLines: 1)),
                      Align(
                          child: Text(right,
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.black)),
                          alignment: Alignment.centerRight)
                    ]))));
  }
}
