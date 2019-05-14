import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart' show required;
import 'package:grade_view/api.dart'
    show Assignment, Breakdown, getMantissaLength, Weighting;

class Course {
  final int period;
  final String name;
  final String id;
  final String location;
  String letterGrade;
  Decimal percentage;
  List<Assignment> assignments;
  final String teacher;
  Breakdown breakdown;
  final int courseMantissaLength;

  Course(
      {@required final String period,
      @required final this.name,
      @required final this.id,
      @required final this.location,
      @required final this.letterGrade,
      @required final String percentage,
      @required final this.teacher})
      : period = int.parse(period),
        percentage = Decimal.parse(percentage),
        courseMantissaLength = getMantissaLength(percentage.toString());

  Course.fromJson(final Map<String, dynamic> json)
      : period = json['period'],
        name = json['name'].indexOf(RegExp(r'\([0-9A-Z]+\)')) >= 0
            ? json['name']
                .substring(0, json['name'].indexOf(RegExp(r'\([0-9A-Z]+\)')))
                .trim()
            : json['name'],
        id = json['name'].indexOf(RegExp(r'\([0-9A-Z]+\)')) >= 0
            ? json['name']
                .substring(json['name'].indexOf(RegExp(r'\([0-9A-Z]+\)')))
                .trim()
            : null,
        location = json['location'],
        letterGrade = json['grades'] != null
            ? json['grades'][json['grades']?.keys?.first]['letter']
            : null,
        percentage = json['grades'] != null
            ? Decimal.tryParse(
                json['grades'][json['grades']?.keys?.first]['percentage'])
            : null,
        teacher = json['teacher'],
        courseMantissaLength = json['grades'] != null
            ? getMantissaLength(
                json['grades'][json['grades']?.keys?.first]['percentage'])
            : null,
        assignments = <Assignment>[],
        breakdown = Breakdown() {
    if (json['assignments'] != null) {
      json['assignments']
          .forEach((final f) => assignments.add(Assignment.fromJson(f)));
      json['grades'][json['grades']?.keys?.first]['breakdown']?.forEach(
          (final String k, final dynamic v) =>
              breakdown.add(Weighting.fromJson(k, v as Map<String, dynamic>)));
      breakdown.sort((final Weighting a, final Weighting b) => a.name == 'TOTAL'
          ? double.maxFinite.toInt()
          : a.name.compareTo(b.name));
    }
  }

  Map<String, String> toJson() => {
        'period': period.toString(),
        'name': name,
        'id': id,
        'location': location,
        'letter_grade': letterGrade,
        'percentage': percentage.toString(),
        'teacher': teacher
      };

  String toString() => toJson().toString();
}
