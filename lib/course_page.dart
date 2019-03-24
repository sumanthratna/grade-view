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

  const AddGradeForm({@required final this.course});

  @override
  State<AddGradeForm> createState() => _AddGradeFormState();
}

class CoursePage extends StatelessWidget {
  final Course course;

  CoursePage({final Key key, @required final this.course}) : super(key: key);

  void addGrade(final BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (final BuildContext context) {
          return AlertDialog(
              title: const Text('Add Grade'),
              content: AddGradeForm(course: course));
        });
  }

  @override
  Widget build(final BuildContext context) {
    const backButton = Padding(
        child: Align(
            child: BackButton(color: Colors.white),
            alignment: Alignment.centerLeft),
        padding: EdgeInsets.only(top: 10.0, bottom: 0.0));

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
                      settings: RouteSettings(name: 'assignment-page'),
                        builder: (final BuildContext context) => AssignmentPage(
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
    final body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          backButton,
          Text(course.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32.0, color: Colors.white)),
          Expanded(
              child: ListView(children: <Widget>[courseInfo, courseGrades]))
        ]));

    return Scaffold(
        body: body,
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Padding(
              padding: EdgeInsets.all(2.5),
              child: FloatingActionButton(
                  tooltip: 'Add Grade',
                  heroTag: 'add',
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => addGrade(context))),
          Padding(
              padding: EdgeInsets.all(2.5),
              child: FloatingActionButton(
                  tooltip: 'Calculate the Grade Needed',
                  heroTag: 'until',
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: () => calculateForGrade(context)))
        ]));
  }

  void calculateForGrade(final BuildContext context) {}
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
  Widget build(final BuildContext context) {
    return Form(
        key: _formKey,
        child: IntrinsicHeight(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
          TextFormField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Assignment Name*'),
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
              items: (List<Weighting>.from(widget.course.breakdown.weightings)
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
                return 'Please Enter a Valid doubleber';
              }
            },
            onSaved: (final String value) =>
                _assignmentAchievedScore = double.tryParse(value),
          ),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Maximum Score'),
              validator: (final String value) {
                if (value.isNotEmpty && double.tryParse(value) == null) {
                  return 'Please Enter a Valid doubleber';
                }
              },
              onSaved: (final String value) =>
                  _assignmentMaxScore = double.tryParse(value)),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Achieved Points*'),
              validator: (final String value) {
                if (value.isEmpty) {
                  return 'Please Enter a Value';
                }
                if (double.tryParse(value) == null) {
                  return 'Please Enter a Valid doubleber';
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
                  return 'Please Enter a Valid doubleber';
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
                  widget.course.assignments =
                      List.from(widget.course.assignments)
                        ..insert(
                            0,
                            Assignment(
                                _assignmentName,
                                _assignmentType,
                                _assignmentDate ?? DateTime.now(),
                                _assignmentDueDate ?? DateTime.now(),
                                _assignmentAchievedScore ??
                                    _assignmentAchievedPoints,
                                _assignmentMaxScore ?? _assignmentMaxPoints,
                                _assignmentAchievedPoints,
                                _assignmentMaxPoints,
                                _assignmentNotes ?? '',
                                real: false));
                  //TODO recalculate breakdown
                  Navigator.pop(context);
                }
              })
        ])));
  }
}
