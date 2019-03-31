import 'package:flutter/material.dart';

import 'api.dart' show Course, Assignment;
import 'custom_widgets.dart' show Info;
import 'globals.dart' show decoration;

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
    final Widget backButton = const Padding(
        child: const Align(
            child: const BackButton(color: Colors.white),
            alignment: Alignment.centerLeft),
        padding: const EdgeInsets.only(top: 10.0, bottom: 0.0));

    final Widget assignmentInfo = ListView(children: <Widget>[
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
    final Widget body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          backButton,
          Center(
              child: Text(assignment.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32.0, color: Colors.white))),
          Expanded(child: assignmentInfo)
        ]));

    return Scaffold(body: body, floatingActionButton: _getDeleteFab(context));
  }

  void _delete(final BuildContext context) => showDialog(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
              title: const Text('Delete Assignment'),
              content: const Text(
                  'Are you sure you want to delete this assignment? This action cannot be undone.'),
              actions: <FlatButton>[
                FlatButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      course.assignments = List.from(course.assignments)
                        ..remove(assignment);
                      //TODO recalculate breakdown
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ]));

  String _formatDate(final DateTime arg) =>
      arg.month.toString() +
      "/" +
      arg.day.toString() +
      "/" +
      arg.year.toString();

  Widget _getDeleteFab(final BuildContext context) => assignment.real
      ? Container()
      : FloatingActionButton(
          tooltip: 'Remove this Assignment',
          heroTag: 'remove',
          child: const Icon(Icons.delete, color: Colors.white),
          onPressed: () => _delete(context),
          backgroundColor: Colors.red);
}
