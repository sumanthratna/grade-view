library widgets;

import 'package:flutter/material.dart'
    show
        Brightness,
        DropdownMenuItem,
        FormFieldSetter,
        InputDecoration,
        Text,
        TextFormField,
        Widget;
import 'package:grade_view/api.dart' show Assignment, Course, Weighting;

import 'src/widgets/dropdown_form_field.dart' show DropdownFormField;

export 'src/widgets/assignments_list.dart' show AssignmentList;
export 'src/widgets/back_bar.dart' show BackBar;
export 'src/widgets/breakdown_table.dart'
    show BreakdownTableSource, BreakdownTable;
export 'src/widgets/dropdown_form_field.dart' show DropdownFormField;
export 'src/widgets/info_card.dart' show InfoCard;
export 'src/widgets/input_text.dart' show InputText;
export 'src/widgets/loading_indicator.dart' show LoadingIndicator;

Widget getAssignmentTypeSelector(final int assignmentTypeSelector,
        final Course course, final FormFieldSetter<String> onSaved) =>
    assignmentTypeSelector == 1
        ? DropdownFormField(
            validator: (final String value) {
              if (value == null || value.isEmpty) {
                return 'Please Select a Value';
              }
            },
            onSaved: onSaved,
            decoration: const InputDecoration(
              labelText: 'Assignment Type*',
            ),
            items: (course.breakdown.map((final Weighting f) => f.name).toList()
                  ..remove('TOTAL'))
                .map((final String f) =>
                    DropdownMenuItem<String>(value: f, child: Text(f)))
                .toList())
        : (assignmentTypeSelector == -1
            ? TextFormField(
                keyboardAppearance: Brightness.dark,
                decoration: const InputDecoration(labelText: 'Assignment Type'),
                onSaved: onSaved)
            : DropdownFormField(
                onSaved: onSaved,
                decoration: const InputDecoration(
                  labelText: 'Assignment Type',
                ),
                items: course.assignments
                    .map((final Assignment f) => f.assignmentType)
                    .toSet()
                    .map((final String f) =>
                        DropdownMenuItem<String>(value: f, child: Text(f)))
                    .toList()));
