import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart'
    show
        StatelessWidget,
        Key,
        required,
        Widget,
        BuildContext,
        Colors,
        EdgeInsets,
        ListView,
        Container,
        MediaQuery,
        Column,
        Center,
        Text,
        TextAlign,
        TextStyle,
        Expanded,
        Scaffold,
        showDialog,
        AlertDialog,
        FlatButton,
        Navigator,
        FloatingActionButton,
        Icon,
        Icons,
        AppBar,
        IconThemeData;

import 'api.dart' show Assignment, Course, Weighting, percentageToLetterGrade;
import 'custom_widgets.dart' show BackBar, Info;
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
    final Widget assignmentInfo = ListView(
        children: <Widget>[
      Info(
        left: "Letter Grade",
        right: percentageToLetterGrade(
            100.0 * assignment.achievedPoints / assignment.maxPoints),
        onTap: () {},
      ),
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
      Info(
          left: "Date",

          // The `substring` is to remove the time.
          right: assignment.date.toIso8601String().substring(0, 10),
          onTap: () {}),
      Info(
          left: "Due Date",
          right: assignment.dueDate.toIso8601String().substring(0, 10),
          onTap: () {}),
      assignment.notes == null || assignment.notes.isEmpty
          ? null
          : Info(left: "Notes", right: assignment.notes, onTap: () {})
    ]..removeWhere((final Widget f) => f == null));

    final Widget body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          Center(
              child: Text(assignment.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32.0, color: Colors.white))),
          Expanded(child: assignmentInfo)
        ]));

    return Scaffold(
        appBar: BackBar(
            appBar: AppBar(
                title:
                    const Text('Back', style: TextStyle(color: Colors.white)),
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: false),
            onTap: () => Navigator.pop(context)),
        body: body,
        floatingActionButton: _getDeleteFab(context));
  }

  void _delete(final BuildContext context) => showDialog(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
              title: const Text('Delete Assignment'),
              content: const Text(
                  'Are you sure you want to delete this assignment? This '
                  'action cannot be undone.'),
              actions: <FlatButton>[
                FlatButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      course.breakdown[assignment.assignmentType]
                          .achievedPoints = (Decimal.parse(course
                                  .breakdown[assignment.assignmentType]
                                  .achievedPoints
                                  .toString()) -
                              Decimal.parse(
                                  assignment.achievedPoints.toString()))
                          .toDouble();
                      course.breakdown[assignment.assignmentType]
                          .maxPoints = (Decimal.parse(course
                                  .breakdown[assignment.assignmentType]
                                  .maxPoints
                                  .toString()) -
                              Decimal.parse(assignment.maxPoints.toString()))
                          .toDouble();
                      course.breakdown[assignment.assignmentType].percentage =
                          double.parse((course
                                      .breakdown[assignment.assignmentType]
                                      .weight *
                                  course.breakdown[assignment.assignmentType]
                                      .achievedPoints /
                                  course.breakdown[assignment.assignmentType]
                                      .maxPoints)
                              .toStringAsFixed(course.courseMantissaLength));
                      course.breakdown["TOTAL"].percentage = double.parse(
                          (course.breakdown.weightings
                                  .map((final Weighting f) =>
                                      f.name == "TOTAL" ? 0.0 : f.percentage)
                                  .reduce((final double a, final double b) =>
                                      a + b))
                              .toStringAsFixed(course.courseMantissaLength));
                      course.breakdown[assignment.assignmentType].letterGrade =
                          percentageToLetterGrade(100.0 *
                              course.breakdown[assignment.assignmentType]
                                  .percentage /
                              course
                                  .breakdown[assignment.assignmentType].weight);
                      course.breakdown["TOTAL"].letterGrade =
                          percentageToLetterGrade(
                              course.breakdown["TOTAL"].percentage);
                      course.assignments = List.from(course.assignments)
                        ..remove(assignment);
                      course.percentage = course.breakdown["TOTAL"].percentage;
                      course.letterGrade =
                          course.breakdown["TOTAL"].letterGrade;
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ]));

  Widget _getDeleteFab(final BuildContext context) => assignment.real
      ? Container()
      : FloatingActionButton(
          tooltip: 'Remove this Assignment',
          heroTag: 'remove',
          child: const Icon(Icons.delete, color: Colors.white),
          onPressed: () => _delete(context),
          backgroundColor: Colors.red);
}
