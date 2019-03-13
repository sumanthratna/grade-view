import 'package:flutter/material.dart';

import 'api.dart' show Course, Assignment;
import 'custom_widgets.dart' show Info;

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
              assignment.maxScore.toString(),
          onTap: () {}),
      Info(
          left: "Points",
          right: assignment.achievedPoints.toString() +
              "/" +
              assignment.maxPoints.toString(),
          onTap: () {}),
      Info(left: "Type", right: assignment.assignmentType, onTap: () {}),
      Info(left: "Teacher", right: course.teacher, onTap: () {}),
      Info(left: "Period", right: course.period.toString(), onTap: () {}),
      Info(left: "Date", right: _formatDate(assignment.date), onTap: () {}),
      Info(
          left: "Due Date",
          right: _formatDate(assignment.dueDate),
          onTap: () {})
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
