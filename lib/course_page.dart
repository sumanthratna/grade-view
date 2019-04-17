import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    show DateTimePickerFormField, InputType;
import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart'
    show
        Brightness,
        StatefulWidget,
        Key,
        State,
        required,
        StatelessWidget,
        BuildContext,
        showDialog,
        AlertDialog,
        Text,
        Widget,
        Padding,
        Colors,
        AppBar,
        EdgeInsets,
        TextAlign,
        TextStyle,
        ListView,
        NeverScrollableScrollPhysics,
        Container,
        MediaQuery,
        Column,
        Expanded,
        Scaffold,
        SingleChildScrollView,
        Card,
        Scrollbar,
        DataTable,
        Axis,
        Navigator,
        MaterialPageRoute,
        RouteSettings,
        MainAxisAlignment,
        FloatingActionButton,
        Icon,
        Icons,
        GlobalKey,
        FormState,
        Form,
        ListBody,
        TextFormField,
        InputDecoration,
        DropdownMenuItem,
        RaisedButton,
        IconThemeData,
        TextInputType;
import 'package:intl/intl.dart' show DateFormat;

import 'api.dart' show Assignment, Course, Weighting, percentageToLetterGrade;
import 'assignment_page.dart' show AssignmentPage;
import 'custom_widgets.dart' show BackBar, Info, DropdownFormField;
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
    final Widget pageTitle = Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(course.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32.0, color: Colors.white)));

    final Widget courseBreakdown = Scrollbar(
        child: SingleChildScrollView(
            child: Card(
                child: DataTable(
                    rows: course.breakdown.getDataRows(),
                    columns: course.breakdown.getDataColumns()),
                margin:
                    const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 16.0)),
            scrollDirection: Axis.horizontal));

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
                    settings: const RouteSettings(name: 'assignment-page'),
                    builder: (final BuildContext context) => AssignmentPage(
                        course: course,
                        assignment: course.assignments[index])))));

    final Widget body = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          pageTitle,
          Expanded(
              child: ListView(
            children: <Widget>[courseBreakdown, courseGrades],
            padding: const EdgeInsets.only(bottom: 112.0),
          ))
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
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: () => calculateForGrade(context)))
        ]));
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
                keyboardAppearance: Brightness.dark,
                decoration:
                    const InputDecoration(labelText: 'Assignment Name*'),
                validator: (final String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                },
                onSaved: (final String value) => _assignmentName = value),
            DropdownFormField(
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
                format: DateFormat('yyyy-MM-dd'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onSaved: (final DateTime value) => _assignmentDate = value),
            DateTimePickerFormField(
                format: DateFormat('yyyy-MM-dd'),
                inputType: InputType.date,
                editable: true,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onSaved: (final DateTime value) => _assignmentDueDate = value),
            TextFormField(
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
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (final String value) => _assignmentNotes = value),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final Assignment newAssignment = Assignment(
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
                        List<Assignment>.from(widget.course.assignments)
                          ..insert(0, newAssignment);
                    widget.course.breakdown[newAssignment.assignmentType]
                        .achievedPoints = (Decimal.parse(widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .achievedPoints
                                .toString()) +
                            Decimal.parse(
                                newAssignment.achievedPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[newAssignment.assignmentType]
                        .maxPoints = (Decimal.parse(widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .maxPoints
                                .toString()) +
                            Decimal.parse(newAssignment.maxPoints.toString()))
                        .toDouble();
                    widget.course.breakdown[newAssignment.assignmentType]
                        .percentage = double.parse((widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .weight *
                            widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .achievedPoints /
                            widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .maxPoints)
                        .toStringAsFixed(widget.course.courseMantissaLength));
                    widget.course.breakdown["TOTAL"]
                        .percentage = double.parse((widget
                            .course.breakdown.weightings
                            .map((final Weighting f) =>
                                f.name == "TOTAL" ? 0.0 : f.percentage)
                            .reduce((final double a, final double b) => a + b))
                        .toStringAsFixed(widget.course.courseMantissaLength));
                    widget.course.breakdown[newAssignment.assignmentType]
                            .letterGrade =
                        percentageToLetterGrade(100.0 *
                            widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .percentage /
                            widget
                                .course
                                .breakdown[newAssignment.assignmentType]
                                .weight);
                    widget.course.breakdown["TOTAL"].letterGrade =
                        percentageToLetterGrade(
                            widget.course.breakdown["TOTAL"].percentage);
                    widget.course.percentage =
                        widget.course.breakdown["TOTAL"].percentage;
                    widget.course.letterGrade =
                        widget.course.breakdown["TOTAL"].letterGrade;
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

  double _desiredCoursePercentage;
  String _assignmentType;
  double _assignmentMaxPoints;

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
                  if (value.isNotEmpty &&
                      double.tryParse(value.replaceAll("%", "")) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) => _desiredCoursePercentage =
                    double.tryParse(value.replaceAll("%", "")),
                decoration: const InputDecoration(
                    labelText: 'Desired Course Percentage*')),
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
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) =>
                    _assignmentMaxPoints = double.tryParse(value),
                decoration: const InputDecoration(
                    labelText: 'Point Value of Assignment*')),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final double amountToImprove =
                        _desiredCoursePercentage - widget.course.percentage;
                    final double necessaryAssignmentTypePercentage =
                        (widget.course.breakdown[_assignmentType].percentage +
                                amountToImprove) /
                            widget.course.breakdown[_assignmentType].weight;
                    final double necessaryAssignmentTypeAchievedPoints =
                        necessaryAssignmentTypePercentage *
                            (widget.course.breakdown[_assignmentType]
                                    .maxPoints +
                                _assignmentMaxPoints);
                    final String necessaryScore =
                        (necessaryAssignmentTypeAchievedPoints -
                                widget.course.breakdown[_assignmentType]
                                    .achievedPoints)
                            .toStringAsFixed(
                                widget.course.courseMantissaLength);
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (final BuildContext context) => AlertDialog(
                            title: const Text('Necessary Score'),
                            content: Text('For an assignment of type '
                                '\'$_assignmentType\' a score of at least '
                                '$necessaryScore/$_assignmentMaxPoints '
                                'is needed.'))).then((final dynamic onValue) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  }
                }),
          ])));
}
