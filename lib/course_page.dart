import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    show DateTimePickerFormField, InputType;
import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart'
    show
        Brightness,
        FontWeight,
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
        TextInputType,
        mustCallSuper,
        protected;
import 'package:intl/intl.dart' show DateFormat;

import 'api.dart'
    show Assignment, Course, Weighting, convertPercentageToLetterGrade;
import 'assignment_page.dart' show AssignmentPage;
import 'custom_widgets.dart' show BackBar, Info, DropdownFormField;
import 'globals.dart' show decoration;

class AddAssignmentForm extends StatefulWidget {
  final Course course;

  const AddAssignmentForm({final Key key, @required final this.course})
      : super(key: key);

  @override
  State<AddAssignmentForm> createState() => _AddAssignmentFormState();
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

  void addAssignment(final BuildContext context) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext context) => AlertDialog(
          title: const Text('Add Grade'),
          content: AddAssignmentForm(course: course)));

  @override
  Widget build(final BuildContext context) {
    final Widget pageTitle = Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(course.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32.0, color: Colors.white)));

    final Widget courseBreakdown = course.breakdown.isEmpty
        ? const Padding(
            child: Text(
              'No Breakdown Information Available',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0))
        : Scrollbar(
            child: SingleChildScrollView(
                child: Card(
                    child: DataTable(
                        rows: course.breakdown.getDataRows(),
                        columns: course.breakdown.getDataColumns()),
                    margin: const EdgeInsets.only(
                        left: 4.0, right: 4.0, bottom: 16.0)),
                scrollDirection: Axis.horizontal));

    final Widget courseAssignments = course.assignments.isEmpty
        ? const Padding(
            child: Text(
              'No Assignments Available',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0))
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: course.assignments.length,
            shrinkWrap: true,
            itemBuilder: (final BuildContext context, final int index) => Info(
                left: course.assignments[index].name,
                right: ' ' +
                    course.assignments[index].achievedPoints.toString() +
                    '/' +
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
            children: <Widget>[courseBreakdown, courseAssignments],
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
                  onPressed: () => addAssignment(context))),
          Padding(
              padding: const EdgeInsets.all(2.5),
              child: FloatingActionButton(
                  tooltip: 'Calculate the Grade Needed',
                  heroTag: 'calc',
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: () async => calculateForGrade(context)))
        ]));
  }

  void calculateForGrade(final BuildContext context) async {
    Map<String, dynamic> data = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: true,
        builder: (final BuildContext context) => AlertDialog(
            title: const Text('Calculate Required Score'),
            content: CalculateRequiredScoreForm(course: course)));
    if (data == null || data.isEmpty) {
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (final BuildContext context) => AlertDialog(
            title: const Text('Necessary Score'),
            content: Text('For an assignment of type '
                '\'${data['assignmentType']}\' a score of at least '
                '${data['necessaryPoints']}/${data['assignmentMaxPoints']} '
                'is needed to achieve a course grade of '
                '${data['desiredCoursePercentage']}%.')));
  }
}

class _AddAssignmentFormState extends State<AddAssignmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _assignmentName;
  String _assignmentType;
  DateTime _assignmentDate;
  DateTime _assignmentDueDate;
  Decimal _assignmentAchievedScore, _assignmentMaxScore;
  Decimal _assignmentAchievedPoints, _assignmentMaxPoints;
  String _assignmentNotes;

  // -1 for a text field.
  // 0 for dropdown with no weightings.
  // 1 for dropdown with weigtings.
  int _assignmentTypeSelector;

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
            _assignmentTypeSelector == 1
                ? DropdownFormField(
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
                        .toList())
                : (_assignmentTypeSelector == -1
                    ? TextFormField(
                        keyboardAppearance: Brightness.dark,
                        decoration:
                            const InputDecoration(labelText: 'Assignment Name'),
                        onSaved: (final String value) =>
                            _assignmentType = value)
                    : DropdownFormField(
                        validator: (final String value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select a Value';
                          }
                        },
                        onSaved: (final String value) =>
                            _assignmentType = value,
                        decoration: const InputDecoration(
                          labelText: 'Assignment Type*',
                        ),
                        items: widget.course.assignments
                            .map((final Assignment f) => f.assignmentType)
                            .toSet()
                            .map((final String f) => DropdownMenuItem<String>(
                                value: f, child: Text(f)))
                            .toList())),
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
                if (value.isNotEmpty && Decimal.tryParse(value) == null) {
                  return 'Please Enter a Valid Number';
                }
              },
              onSaved: (final String value) =>
                  _assignmentAchievedScore = Decimal.tryParse(value),
            ),
            TextFormField(
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
                decoration: const InputDecoration(labelText: 'Notes'),
                keyboardAppearance: Brightness.dark,
                onSaved: (final String value) => _assignmentNotes = value),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final Assignment newAssignment = Assignment(
                        name: _assignmentName,
                        assignmentType: _assignmentType ?? 'N/A',
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
                    if (_assignmentTypeSelector == -1) {
                      final Decimal newPercentage = Decimal.fromInt(100) *
                          _assignmentAchievedPoints /
                          _assignmentMaxPoints;
                      widget.course.percentage = newPercentage;
                      widget.course.letterGrade =
                          convertPercentageToLetterGrade(newPercentage);
                    } else if (_assignmentTypeSelector == 0) {
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
                      widget.course.breakdown[_assignmentType].achievedPoints =
                          widget.course.breakdown[_assignmentType]
                                  .achievedPoints +
                              _assignmentAchievedPoints;
                      widget.course.breakdown[_assignmentType].maxPoints =
                          widget.course.breakdown[_assignmentType].maxPoints +
                              _assignmentMaxPoints;
                      widget.course.breakdown[_assignmentType].percentage =
                          Decimal.parse(
                              (widget.course.breakdown[_assignmentType].weight *
                                      widget.course.breakdown[_assignmentType]
                                          .achievedPoints /
                                      widget.course.breakdown[_assignmentType]
                                          .maxPoints)
                                  .toStringAsFixed(widget
                                      .course
                                      .breakdown[_assignmentType]
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
                      widget.course.breakdown[_assignmentType].letterGrade =
                          convertPercentageToLetterGrade(Decimal.fromInt(100) *
                              widget.course.breakdown[_assignmentType]
                                  .percentage /
                              widget.course.breakdown[_assignmentType].weight);
                      widget.course.breakdown['TOTAL'].letterGrade =
                          widget.course.letterGrade =
                              convertPercentageToLetterGrade(
                                  widget.course.breakdown['TOTAL'].percentage);
                      widget.course.percentage =
                          widget.course.breakdown['TOTAL'].percentage;
                    }
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

  @protected
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    if (widget.course.assignments.isEmpty) {
      // There are no assignments yet.
      _assignmentTypeSelector = -1;
    } else if (widget.course.breakdown.isEmpty) {
      // There is no breakdown information, so all assignments are weighted equally.
      _assignmentTypeSelector = 0;
    } else {
      // There are weighted assignments.
      _assignmentTypeSelector = 1;
    }
  }
}

class _CalculateRequiredScoreFormState
    extends State<CalculateRequiredScoreForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Decimal _desiredCoursePercentage;
  String _assignmentType;
  Decimal _assignmentMaxPoints;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: ListBody(children: <Widget>[
            TextFormField(
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (value.isNotEmpty &&
                      Decimal.tryParse(value.replaceAll('%', '')) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                onSaved: (final String value) => _desiredCoursePercentage =
                    Decimal.tryParse(value.replaceAll('%', '')),
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
                          ..remove('TOTAL'))
                    .map((final String f) =>
                        DropdownMenuItem<String>(value: f, child: Text(f)))
                    .toList()),
            TextFormField(
                validator: (final String value) {
                  if (value.isEmpty) {
                    return 'Please Enter a Value';
                  }
                  if (value.isNotEmpty && Decimal.tryParse(value) == null) {
                    return 'Please Enter a Valid Number';
                  }
                },
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                keyboardAppearance: Brightness.dark,
                onSaved: (final String value) =>
                    _assignmentMaxPoints = Decimal.tryParse(value),
                decoration: const InputDecoration(
                    labelText: 'Point Value of Assignment*')),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final Decimal amountToImprove =
                        _desiredCoursePercentage - widget.course.percentage;
                    final Decimal necessaryAssignmentTypePercentage =
                        (widget.course.breakdown[_assignmentType].percentage +
                                amountToImprove) /
                            widget.course.breakdown[_assignmentType].weight;
                    final Decimal necessaryAssignmentTypeAchievedPoints =
                        necessaryAssignmentTypePercentage *
                            (widget.course.breakdown[_assignmentType]
                                    .maxPoints +
                                _assignmentMaxPoints);
                    final String necessaryPoints =
                        (necessaryAssignmentTypeAchievedPoints -
                                widget.course.breakdown[_assignmentType]
                                    .achievedPoints)
                            .toStringAsFixed(widget.course.breakdown['TOTAL']
                                .weightingMantissaLength);
                    Map<String, dynamic> data = {
                      'assignmentType': _assignmentType,
                      'necessaryPoints': necessaryPoints,
                      'assignmentMaxPoints': _assignmentMaxPoints,
                      'desiredCoursePercentage': _desiredCoursePercentage
                    };
                    Navigator.pop(context, data);
                  }
                }),
          ])));
}
