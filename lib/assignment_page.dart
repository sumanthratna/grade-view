import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    show DateTimePickerFormField, InputType;
import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart'
    show
        Padding,
        StatelessWidget,
        StatefulWidget,
        SingleChildScrollView,
        Brightness,
        TextInputType,
        Form,
        ListBody,
        TextFormField,
        InputDecoration,
        State,
        GlobalKey,
        FormState,
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
        IconThemeData,
        MainAxisAlignment,
        DropdownMenuItem,
        RaisedButton;
import 'package:intl/intl.dart' show DateFormat;

import 'api.dart'
    show Assignment, Course, Weighting, convertPercentageToLetterGrade;
import 'custom_widgets.dart' show BackBar, Info, DropdownFormField;
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
        padding:
            assignment.real ? EdgeInsets.zero : EdgeInsets.only(bottom: 112.0),
        children: <Widget>[
          Info(
            left: "Letter Grade",
            right: assignment.achievedPoints == null
                ? "N/A"
                : convertPercentageToLetterGrade(
                    100.0 * assignment.achievedPoints / assignment.maxPoints),
            onTap: () {},
          ),
          Info(
              left: "Score",
              right: (assignment.achievedScore == null &&
                      assignment.maxScore == null)
                  ? "N/A"
                  : assignment.achievedScore.toString() +
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
              ? Container()
              : Info(left: "Notes", right: assignment.notes, onTap: () {})
        ]);

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
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Padding(padding: EdgeInsets.all(2.5), child: _getEditFab(context)),
          Padding(padding: EdgeInsets.all(2.5), child: _getDeleteFab(context)),
        ]));
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
                                  .reduce((final double value,
                                          final double element) =>
                                      value + element))
                              .toStringAsFixed(course.courseMantissaLength));
                      course.breakdown[assignment.assignmentType].letterGrade =
                          convertPercentageToLetterGrade(100.0 *
                              course.breakdown[assignment.assignmentType]
                                  .percentage /
                              course
                                  .breakdown[assignment.assignmentType].weight);
                      course.breakdown["TOTAL"].letterGrade =
                          convertPercentageToLetterGrade(
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

  void _edit(final BuildContext context) => showDialog(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
          title: const Text('Edit Assignment'),
          content: EditAssignmentForm(
            course: course,
            assignment: assignment,
          )));

  Widget _getDeleteFab(final BuildContext context) => assignment.real
      ? Container()
      : FloatingActionButton(
          tooltip: 'Remove this Assignment',
          heroTag: 'remove',
          child: const Icon(Icons.delete, color: Colors.white),
          onPressed: () => _delete(context),
          backgroundColor: Colors.red);

  Widget _getEditFab(final BuildContext context) => assignment.real
      ? Container()
      : FloatingActionButton(
          tooltip: 'Edit this Assignment',
          heroTag: 'edit',
          child: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _edit(context));
}

class EditAssignmentForm extends StatefulWidget {
  final Course course;
  final Assignment assignment;

  const EditAssignmentForm(
      {final Key key, @required this.course, @required this.assignment})
      : super(key: key);

  @override
  State<EditAssignmentForm> createState() => _EditAssignmentFormState();
}

class _EditAssignmentFormState extends State<EditAssignmentForm> {
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
                keyboardAppearance: Brightness.dark,
                initialValue: widget.assignment.name,
                decoration:
                    const InputDecoration(labelText: 'Assignment Name*'),
                validator: (final String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                },
                onSaved: (final String value) => _assignmentName = value),
            DropdownFormField(
                initialValue: widget.assignment.assignmentType,
                validator: (final String value) {
                  if (value == null || value.isEmpty) {
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
                initialValue: widget.assignment.date,
                format: DateFormat('yyyy-MM-dd'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onSaved: (final DateTime value) => _assignmentDate = value),
            DateTimePickerFormField(
                initialValue: widget.assignment.dueDate,
                format: DateFormat('yyyy-MM-dd'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onSaved: (final DateTime value) => _assignmentDueDate = value),
            TextFormField(
              initialValue: widget.assignment.achievedScore.toString(),
              decoration: const InputDecoration(labelText: 'Achieved Score'),
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              keyboardAppearance: Brightness.dark,
              validator: (final String value) {
                if (value.isNotEmpty && double.tryParse(value) == null) {
                  return 'Please Enter a Valid Number';
                }
              },
              onSaved: (final String value) =>
                  _assignmentAchievedScore = double.tryParse(value),
            ),
            TextFormField(
                initialValue: widget.assignment.maxScore.toString(),
                decoration: const InputDecoration(labelText: 'Maximum Score'),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                validator: (final String value) {
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxScore = double.tryParse(value)),
            TextFormField(
                initialValue: widget.assignment.achievedPoints.toString(),
                decoration:
                    const InputDecoration(labelText: 'Achieved Points*'),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                validator: (final String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentAchievedPoints = double.tryParse(value)),
            TextFormField(
                initialValue: widget.assignment.maxPoints.toString(),
                decoration: const InputDecoration(labelText: 'Maximum Points*'),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                validator: (final String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxPoints = double.tryParse(value)),
            TextFormField(
                initialValue: widget.assignment.notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (final String value) => _assignmentNotes = value),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    widget.course.breakdown[widget.assignment.assignmentType]
                        .achievedPoints = (Decimal.parse(widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .achievedPoints
                                .toString()) -
                            Decimal.parse(
                                widget.assignment.achievedPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[widget.assignment.assignmentType]
                        .maxPoints = (Decimal.parse(widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .maxPoints
                                .toString()) -
                            Decimal.parse(
                                widget.assignment.maxPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[widget.assignment.assignmentType]
                        .percentage = double.parse((widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .weight *
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .achievedPoints /
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .maxPoints)
                        .toStringAsFixed(widget.course.courseMantissaLength));
                    widget.course.breakdown[widget.assignment.assignmentType]
                            .letterGrade =
                        convertPercentageToLetterGrade(100.0 *
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .percentage /
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .weight);

                    widget.assignment.name = _assignmentName;
                    widget.assignment.assignmentType = _assignmentType;
                    widget.assignment.date = _assignmentDate;
                    widget.assignment.dueDate = _assignmentDueDate;
                    widget.assignment.achievedScore =
                        _assignmentAchievedScore ?? _assignmentAchievedPoints;
                    widget.assignment.maxScore =
                        _assignmentMaxScore ?? _assignmentMaxPoints;
                    widget.assignment.achievedPoints =
                        _assignmentAchievedPoints;
                    widget.assignment.maxPoints = _assignmentMaxPoints;
                    widget.assignment.notes = _assignmentNotes ?? '';
                    setState(() => widget.course.assignments =
                        List<Assignment>.from(widget.course.assignments));

                    widget.course.breakdown[widget.assignment.assignmentType]
                        .achievedPoints = (Decimal.parse(widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .achievedPoints
                                .toString()) +
                            Decimal.parse(
                                widget.assignment.achievedPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[widget.assignment.assignmentType]
                        .maxPoints = (Decimal.parse(widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .maxPoints
                                .toString()) +
                            Decimal.parse(
                                widget.assignment.maxPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[widget.assignment.assignmentType]
                        .percentage = double.parse((widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .weight *
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .achievedPoints /
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .maxPoints)
                        .toStringAsFixed(widget
                            .course
                            .breakdown[widget.assignment.assignmentType]
                            .weightingMantissaLength));

                    widget.course.breakdown["TOTAL"].percentage = double.parse(
                        (widget.course.breakdown.weightings
                                .map((final Weighting f) =>
                                    f.name == "TOTAL" ? 0.0 : f.percentage)
                                .reduce((final double value,
                                        final double element) =>
                                    value + element))
                            .toStringAsFixed(widget.course.breakdown["TOTAL"]
                                .weightingMantissaLength));
                    widget.course.breakdown[widget.assignment.assignmentType]
                            .letterGrade =
                        convertPercentageToLetterGrade(100.0 *
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .percentage /
                            widget
                                .course
                                .breakdown[widget.assignment.assignmentType]
                                .weight);
                    widget.course.letterGrade =
                        widget.course.breakdown["TOTAL"].letterGrade =
                            convertPercentageToLetterGrade(
                                widget.course.breakdown["TOTAL"].percentage);
                    widget.course.percentage = double.parse(widget
                        .course.breakdown["TOTAL"].percentage
                        .toStringAsFixed(widget.course.courseMantissaLength));
                    Navigator.pop(context);
                  }
                })
          ])));
}
