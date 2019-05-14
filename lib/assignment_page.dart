import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    show DateTimePickerFormField, InputType;
import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        Brightness,
        BuildContext,
        Center,
        Colors,
        Column,
        Container,
        DropdownMenuItem,
        EdgeInsets,
        Expanded,
        FlatButton,
        FloatingActionButton,
        Form,
        FormState,
        GlobalKey,
        Icon,
        Icons,
        IconThemeData,
        InputDecoration,
        Key,
        ListBody,
        ListView,
        MainAxisAlignment,
        MediaQuery,
        Navigator,
        Padding,
        RaisedButton,
        required,
        Scaffold,
        showDialog,
        SingleChildScrollView,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextAlign,
        TextFormField,
        TextInputType,
        TextStyle,
        Widget;
import 'package:grade_view/widgets.dart'
    show BackBar, DropdownFormField, InfoCard;
import 'package:intl/intl.dart' show DateFormat;

import 'package:grade_view/api.dart'
    show Assignment, Course, Weighting, convertPercentageToLetterGrade;
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
    final Decimal percentage = assignment.achievedPoints == null
        ? null
        : Decimal.fromInt(100) *
            assignment.achievedPoints /
            assignment.maxPoints;
    final Widget assignmentInfo = ListView(
        padding:
            assignment.real ? EdgeInsets.zero : EdgeInsets.only(bottom: 112.0),
        children: <Widget>[
          InfoCard(
            left: 'Letter Grade',
            right: percentage == null
                ? 'N/A'
                : convertPercentageToLetterGrade(percentage),
            onTap: () {},
          ),
          InfoCard(
            left: 'Percentage',
            right: percentage == null
                ? 'N/A'
                : percentage.toStringAsFixed(
                        course.breakdown == null || course.breakdown.isEmpty
                            ? course.courseMantissaLength
                            : course.breakdown[assignment.assignmentType]
                                .weightingMantissaLength) +
                    '%',
            onTap: () {},
          ),
          InfoCard(
              left: 'Score',
              right: (assignment.achievedScore == null &&
                      assignment.maxScore == null)
                  ? 'N/A'
                  : assignment.achievedScore.toString() +
                      '/' +
                      assignment.maxScore.toString(),
              onTap: () {}),
          InfoCard(
              left: 'Points',
              right: assignment.achievedPoints.toString() +
                  '/' +
                  assignment.maxPoints.toString(),
              onTap: () {}),
          InfoCard(
              left: 'Type',
              right: assignment.assignmentType ?? 'N/A',
              onTap: () {}),
          InfoCard(left: 'Teacher', right: course.teacher, onTap: () {}),
          InfoCard(
              left: 'Period', right: course.period.toString(), onTap: () {}),
          InfoCard(
              left: 'Date',
              right: assignment.date.toIso8601String().substring(0, 10),
              onTap: () {}),
          InfoCard(
              left: 'Due Date',
              right: assignment.dueDate.toIso8601String().substring(0, 10),
              onTap: () {}),
          assignment.notes == null || assignment.notes.isEmpty
              ? Container()
              : InfoCard(left: 'Notes', right: assignment.notes, onTap: () {})
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
                      if (course.breakdown.isEmpty) {
                        if (course.assignments.length == 1) {
                          final Decimal newCoursePercentage = Decimal.parse(
                              0.toStringAsFixed(course.courseMantissaLength));
                          course.percentage = newCoursePercentage;
                          course.letterGrade = 'N/A';
                        } else {
                          final Decimal originalCourseMaxPoints = course
                              .assignments
                              .map((final Assignment e) => e.maxPoints)
                              .reduce((final Decimal element,
                                      final Decimal value) =>
                                  element + value);
                          final Decimal originalCourseAchievedPoints = course
                              .assignments
                              .map((final Assignment e) => e.achievedPoints)
                              .reduce((final Decimal element,
                                      final Decimal value) =>
                                  element + value);
                          final Decimal newCourseMaxPoints =
                              originalCourseMaxPoints - assignment.maxPoints;
                          final Decimal newCourseAchievedPoints =
                              originalCourseAchievedPoints -
                                  assignment.achievedPoints;
                          final Decimal newCoursePercentage =
                              Decimal.fromInt(100) *
                                  newCourseAchievedPoints /
                                  newCourseMaxPoints;
                          course.percentage = newCoursePercentage;
                          course.letterGrade = convertPercentageToLetterGrade(
                              newCoursePercentage);
                        }
                      } else {
                        course.breakdown[assignment.assignmentType]
                            .achievedPoints = course
                                .breakdown[assignment.assignmentType]
                                .achievedPoints -
                            assignment.achievedPoints;
                        course.breakdown[assignment.assignmentType].maxPoints =
                            course.breakdown[assignment.assignmentType]
                                    .maxPoints -
                                assignment.maxPoints;
                        course.breakdown[assignment.assignmentType].percentage =
                            Decimal.parse((course
                                        .breakdown[assignment.assignmentType]
                                        .weight *
                                    course.breakdown[assignment.assignmentType]
                                        .achievedPoints /
                                    course.breakdown[assignment.assignmentType]
                                        .maxPoints)
                                .toStringAsFixed(course.courseMantissaLength));
                        course.breakdown['TOTAL']
                            .percentage = Decimal.parse((course
                                .breakdown.weightings
                                .map((final Weighting f) => f.name == 'TOTAL'
                                    ? Decimal.fromInt(0)
                                    : f.percentage)
                                .reduce((final Decimal value,
                                        final Decimal element) =>
                                    value + element))
                            .toStringAsFixed(course.courseMantissaLength));
                        course.breakdown[assignment.assignmentType]
                                .letterGrade =
                            convertPercentageToLetterGrade(
                                Decimal.fromInt(100) *
                                    course.breakdown[assignment.assignmentType]
                                        .percentage /
                                    course.breakdown[assignment.assignmentType]
                                        .weight);
                        course.breakdown['TOTAL'].letterGrade =
                            convertPercentageToLetterGrade(
                                course.breakdown['TOTAL'].percentage);
                        course.percentage =
                            course.breakdown['TOTAL'].percentage;
                        course.letterGrade =
                            course.breakdown['TOTAL'].letterGrade;
                      }
                      course.assignments = List.from(course.assignments)
                        ..remove(assignment);
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
  Decimal _assignmentAchievedScore, _assignmentMaxScore;
  Decimal _assignmentAchievedPoints, _assignmentMaxPoints;
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
                          ..remove('TOTAL'))
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
                if (value.isNotEmpty && Decimal.tryParse(value) == null) {
                  return 'Please Enter a Valid Number';
                }
              },
              onSaved: (final String value) =>
                  _assignmentAchievedScore = Decimal.tryParse(value),
            ),
            TextFormField(
                initialValue: widget.assignment.maxScore.toString(),
                decoration: const InputDecoration(labelText: 'Maximum Score'),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                validator: (final String value) {
                  if (value.isNotEmpty && Decimal.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxScore = Decimal.tryParse(value)),
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
                  if (Decimal.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentAchievedPoints = Decimal.tryParse(value)),
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
                  if (Decimal.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxPoints = Decimal.tryParse(value)),
            TextFormField(
                initialValue: widget.assignment.notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (final String value) => _assignmentNotes = value),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    void updateAssignment() {
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
                    }

                    _formKey.currentState.save();
                    if (widget.course.breakdown.isEmpty) {
                      updateAssignment();
                      final Decimal newCourseAchievedPoints = widget
                          .course.assignments
                          .map((final Assignment e) => e.achievedPoints)
                          .reduce(
                              (final Decimal element, final Decimal value) =>
                                  element + value);
                      final Decimal newCourseMaxPoints = widget
                          .course.assignments
                          .map((final Assignment e) => e.maxPoints)
                          .reduce(
                              (final Decimal element, final Decimal value) =>
                                  element + value);
                      final Decimal newCoursePercentage = Decimal.fromInt(100) *
                          newCourseAchievedPoints /
                          newCourseMaxPoints;
                      widget.course.percentage = newCoursePercentage;
                      widget.course.letterGrade =
                          convertPercentageToLetterGrade(newCoursePercentage);
                    } else {
                      widget.course.breakdown[widget.assignment.assignmentType]
                          .achievedPoints = widget
                              .course
                              .breakdown[widget.assignment.assignmentType]
                              .achievedPoints -
                          widget.assignment.achievedPoints;
                      widget.course.breakdown[widget.assignment.assignmentType]
                          .maxPoints = widget
                              .course
                              .breakdown[widget.assignment.assignmentType]
                              .maxPoints -
                          widget.assignment.maxPoints;
                      widget.course.breakdown[widget.assignment.assignmentType]
                          .percentage = Decimal.parse((widget
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
                          convertPercentageToLetterGrade(Decimal.fromInt(100) *
                              widget
                                  .course
                                  .breakdown[widget.assignment.assignmentType]
                                  .percentage /
                              widget
                                  .course
                                  .breakdown[widget.assignment.assignmentType]
                                  .weight);
                      updateAssignment();

                      widget.course.breakdown[widget.assignment.assignmentType]
                          .achievedPoints = widget
                              .course
                              .breakdown[widget.assignment.assignmentType]
                              .achievedPoints +
                          widget.assignment.achievedPoints;
                      widget.course.breakdown[widget.assignment.assignmentType]
                          .maxPoints = widget
                              .course
                              .breakdown[widget.assignment.assignmentType]
                              .maxPoints +
                          widget.assignment.maxPoints;
                      widget.course.breakdown[widget.assignment.assignmentType]
                          .percentage = Decimal.parse((widget
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

                      widget.course.breakdown['TOTAL'].percentage =
                          Decimal.parse((widget.course.breakdown.weightings
                                  .map((final Weighting f) => f.name == 'TOTAL'
                                      ? Decimal.fromInt(0)
                                      : f.percentage)
                                  .reduce((final Decimal value,
                                          final Decimal element) =>
                                      value + element))
                              .toStringAsFixed(widget.course.breakdown['TOTAL']
                                  .weightingMantissaLength));
                      widget.course.breakdown[widget.assignment.assignmentType]
                              .letterGrade =
                          convertPercentageToLetterGrade(Decimal.fromInt(100) *
                              widget
                                  .course
                                  .breakdown[widget.assignment.assignmentType]
                                  .percentage /
                              widget
                                  .course
                                  .breakdown[widget.assignment.assignmentType]
                                  .weight);
                      widget.course.letterGrade =
                          widget.course.breakdown['TOTAL'].letterGrade =
                              convertPercentageToLetterGrade(
                                  widget.course.breakdown['TOTAL'].percentage);
                      widget.course.percentage = Decimal.parse(widget
                          .course.breakdown['TOTAL'].percentage
                          .toStringAsFixed(widget.course.courseMantissaLength));
                    }
                    Navigator.pop(context);
                  }
                })
          ])));
}
