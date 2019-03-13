import 'package:flutter/material.dart';

import 'api.dart' show Course;
import 'assignment_page.dart' show AssignmentPage;
import 'custom_widgets.dart' show Info;

class CoursePage extends StatelessWidget {
  final Course course;

  CoursePage({final Key key, @required final this.course}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final backButton = const Padding(
        child: const Align(
            child: const BackButton(color: Colors.white),
            alignment: Alignment.centerLeft),
        padding: const EdgeInsets.only(top: 10.0, bottom: 0.0));

    final courseInfo = Card(
        child: DataTable(
            rows: course.breakdown.getDataRows(),
            columns: course.breakdown.getDataColumns()),
        margin: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 15.0));

    final courseGrades = ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: course.assignments.length,
        shrinkWrap: true,
        itemBuilder: (final BuildContext context, final int index) {
          return Info(
              left: course.assignments[index].name,
              right: " " +
                  course.assignments[index].achievedPoints.toString() +
                  "/" +
                  course.assignments[index].maxPoints.toString(),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (final context) => AssignmentPage(
                            course: course,
                            assignment: course.assignments[index])));
              });
        });
    /* looks weird
    final body = Dismissible(
      key: Key('body'),
      onDismissed: (direction) {
        Navigator.of(context).pop();
      },
      child: Container(
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
          Text(course.name,
              style: TextStyle(fontSize: 32.0, color: Colors.white)),
          Expanded(
              child: ListView(children: <Widget>[courseInfo, courseGrades]))
        ])));
    */
    final body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ]),
        ),
        child: Column(children: <Widget>[
          backButton,
          Text(course.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32.0, color: Colors.white)),
          Expanded(
              child: ListView(children: <Widget>[courseInfo, courseGrades]))
        ]));

    return Scaffold(body: body);
  }
}
