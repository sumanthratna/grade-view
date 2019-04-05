import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    show DateTimePickerFormField, InputType;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'api.dart' show Course, Assignment, Weighting;
import 'assignment_page.dart' show AssignmentPage;
import 'custom_widgets.dart' show Info, DropdownFormField;
import 'globals.dart' show decoration;

class AddGradeForm extends StatefulWidget {
  final Course course;

  const AddGradeForm({final Key key, @required final this.course})
      : super(key: key);

  @override
  State<AddGradeForm> createState() => _AddGradeFormState();
}

class CalculateRequiredScoreForm extends StatefulWidget {
  final Course course;

  const CalculateRequiredScoreForm({final Key key, @required final this.course})
      : super(key: key);

  @override
  State<CalculateRequiredScoreForm> createState() =>
      _CalculateRequiredScoreFormState();
}

class CoursePage extends StatelessWidget {
  final Course course;

  CoursePage({final Key key, @required final this.course}) : super(key: key);

  void addGrade(final BuildContext context) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext context) => AlertDialog(
          title: const Text('Add Grade'),
          content: AddGradeForm(course: course)));

  @override
  Widget build(final BuildContext context) {
    const Widget backButton = Padding(
        child: Align(
            child: BackButton(color: Colors.white),
            alignment: Alignment.centerLeft),
        padding: EdgeInsets.only(top: 10.0, bottom: 0.0));

    final Widget pageTitle = Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(course.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32.0, color: Colors.white)));

    /// If [showCourseInfo] is `true`, course information will be shown but not grades.
    /// This will be `true` if [_successDuringGradesFetch] in [HomePage] is `false`.
    /// In other words, if grades are not available, course information is shown.
    final bool showCourseInfo = (course.percentage == null &&
        course.letterGrade == null &&
        course.assignments.isEmpty &&
        course.breakdown.isEmpty &&
        course.courseMantissaLength == null);

    if (showCourseInfo) {
      final Widget courseInfo = ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Info(left: "Period", right: course.period.toString(), onTap: () {}),
            Info(left: "Location", right: course.location, onTap: () {}),
            Info(left: "Teacher", right: course.teacher, onTap: () {})
          ]);
      final Widget body = Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(28.0),
          decoration: decoration,
          child: Column(children: <Widget>[
            backButton,
            pageTitle,
            Expanded(
                child: ListView(children: <Widget>[
              const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Grades are currently not available.",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                    textAlign: TextAlign.center,
                  )),
              courseInfo
            ]))
          ]));
      return Scaffold(body: body);
    } else {
      final Widget courseBreakdown = SingleChildScrollView(
          child: Card(
              child: DataTable(
                  rows: course.breakdown.getDataRows(),
                  columns: course.breakdown.getDataColumns()),
              margin:
                  const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 16.0)),
          scrollDirection: Axis.horizontal);

      final Widget courseGrades = ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: course.assignments.length,
          shrinkWrap: true,
          itemBuilder: (final BuildContext context, final int index) => Info(
              left: course.assignments[index].name,
              right: " " +
                  course.assignments[index].achievedPoints.toString() +
                  "/" +
                  course.assignments[index].maxPoints.toString(),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: 'assignment-page'),
                      builder: (final BuildContext context) => AssignmentPage(
                          course: course,
                          assignment: course.assignments[index])))));
      /* looks weird
    final body = Dismissible(
      key: Key('body'),
      onDismissed: (direction) {
        Navigator.of(context).pop();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(28.0),
        decoration: decoration,
        ),
        child: Column(children: <Widget>[
          backButton,
          Text(course.name,
              style: TextStyle(fontSize: 32.0, color: Colors.white)),
          Expanded(
              child: ListView(children: <Widget>[courseInfo, courseGrades]))
        ])));
    */
      final Widget body = Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(28.0),
          decoration: decoration,
          child: Column(children: <Widget>[
            backButton,
            pageTitle,
            Expanded(
                child: ListView(
              children: <Widget>[courseBreakdown, courseGrades],
              padding: const EdgeInsets.only(bottom: 112.0),
            ))
          ]));

      return Scaffold(
          body: body,
          floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: FloatingActionButton(
                        tooltip: 'Add Grade',
                        heroTag: 'add',
                        child: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => addGrade(context))),
                Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: FloatingActionButton(
                        tooltip: 'Calculate the Grade Needed',
                        heroTag: 'calc',
                        child:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: () => calculateForGrade(context)))
              ]));
    }
  }

  void calculateForGrade(final BuildContext context) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext context) => AlertDialog(
          title: const Text('Calculate Required Score'),
          content: CalculateRequiredScoreForm(course: course)));
}

class _AddGradeFormState extends State<AddGradeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _assignmentName;
  String _assignmentType;
  DateTime _assignmentDate;
  DateTime _assignmentDueDate;
  double _assignmentAchievedScore, _assignmentMaxScore;
  double _assignmentAchievedPoints, _assignmentMaxPoints;
  String _assignmentNotes;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: ListBody(children: <Widget>[
            TextFormField(
                autofocus: true,
                decoration:
                    const InputDecoration(labelText: 'Assignment Name*'),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                },
                onSaved: (final String value) => _assignmentName = value),
            DropdownFormField(
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Select a Value';
                  }
                },
                onSaved: (final String value) => _assignmentType = value,
                decoration: const InputDecoration(
                  labelText: 'Assignment Type*',
                ),
                items: (List<Weighting>.from(widget.course.breakdown)
                        .map((final Weighting f) => f.name)
                        .toList()
                          ..remove("TOTAL"))
                    .map((final String f) =>
                        DropdownMenuItem<String>(value: f, child: Text(f)))
                    .toList()),
            DateTimePickerFormField(
                format: DateFormat('MM/dd/yyyy'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onSaved: (final DateTime value) => _assignmentDate = value),
            DateTimePickerFormField(
                format: DateFormat('MM/dd/yyyy'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onSaved: (final DateTime value) => _assignmentDueDate = value),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Achieved Score'),
              validator: (final String value) {
                if (value.isNotEmpty && double.tryParse(value) == null) {
                  return 'Please Enter a Valid Number';
                }
              },
              onSaved: (final String value) =>
                  _assignmentAchievedScore = double.tryParse(value),
            ),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Maximum Score'),
                validator: (final String value) {
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxScore = double.tryParse(value)),
            TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Achieved Points*'),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentAchievedPoints = double.tryParse(value)),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Maximum Points*'),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxPoints = double.tryParse(value)),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (final String value) => _assignmentNotes = value),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Assignment newAssignment = Assignment(
                        name: _assignmentName,
                        assignmentType: _assignmentType,
                        date: _assignmentDate ?? DateTime.now(),
                        dueDate: _assignmentDueDate ?? DateTime.now(),
                        achievedScore: _assignmentAchievedScore ??
                            _assignmentAchievedPoints,
                        maxScore: _assignmentMaxScore ?? _assignmentMaxPoints,
                        achievedPoints: _assignmentAchievedPoints,
                        maxPoints: _assignmentMaxPoints,
                        notes: _assignmentNotes ?? '',
                        real: false);
                    widget.course.assignments =
                        List.from(widget.course.assignments)
                          ..insert(0, newAssignment);
                    //TODO recalculate breakdown
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: RouteSettings(name: 'assignment-page'),
                            builder: (final BuildContext context) =>
                                AssignmentPage(
                                    course: widget.course,
                                    assignment: newAssignment)));
                  }
                })
          ])));
}

class _CalculateRequiredScoreFormState
    extends State<CalculateRequiredScoreForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double _desiredGrade;
  String _assignmentType;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: ListBody(children: <Widget>[
            TextFormField(
                autofocus: true,
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _desiredGrade = double.tryParse(value),
                decoration: const InputDecoration(labelText: 'Desired Score*')),
            DropdownFormField(
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Select a Value';
                  }
                },
                onSaved: (final String value) => _assignmentType = value,
                decoration: const InputDecoration(
                  labelText: 'Assignment Type*',
                ),
                items: (widget.course.breakdown
                        .map((final Weighting f) => f.name)
                        .toList()
                          ..remove("TOTAL"))
                    .map((final String f) =>
                        DropdownMenuItem<String>(value: f, child: Text(f)))
                    .toList()),
            TextFormField(
                autofocus: true,
                validator: (final String value) {
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _desiredGrade = double.tryParse(value),
                decoration: const InputDecoration(
                    labelText: 'Point Value of Assignment')),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Navigator.pop(context);
                  }
                }),
          ])));
}
