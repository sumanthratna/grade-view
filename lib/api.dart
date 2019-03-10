import 'dart:async' show Future;
import 'dart:convert' show base64, base64Encode, utf8;

import 'package:flutter/material.dart'
    show Text, Image, DataRow, DataColumn, DataCell;
import 'package:http/http.dart' as http show get;

class API {
  static const String _base = "https://sisapi.sites.tjhsst.edu";
  static Future getGrades(final String username, final String password) {
    final String url = _base + "/grades/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future getUser(final String username, final String password) {
    final String url = _base + "/user/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }
}

class Assignment {
  String name;
  String assignmentType;
  DateTime date;
  DateTime dueDate;
  double achievedScore, maxScore;
  double achievedPoints, maxPoints;
  String notes;

  Assignment(
      final String name,
      final String assignmentType,
      final String date,
      final String dueDate,
      final String achievedScore,
      final String maxScore,
      final String achievedPoints,
      final String maxPoints,
      final String notes)
      : name = name,
        assignmentType = assignmentType,
        date = DateTime.parse(date),
        dueDate = DateTime.parse(dueDate),
        achievedScore = double.parse(achievedScore),
        maxScore = double.parse(maxScore),
        achievedPoints = double.parse(achievedPoints),
        maxPoints = double.parse(maxPoints),
        notes = notes;

  Assignment.fromJson(final Map<String, dynamic> json) {
    name = json['name'];
    assignmentType = json['assignment_type'];
    date = DateTime.parse(json['date']);
    dueDate = DateTime.parse(json['due_date']);
    final score = json['score'].split(' out of ');
    achievedScore = double.tryParse(score[0]);
    maxScore = double.tryParse(score[score.length == 2 ? 1 : 0]);
    final points = json['points'].split(' / ');
    achievedPoints = double.tryParse(points[0]);
    maxPoints = double.tryParse(
        points.length == 2 ? points[1] : points[0].split(' ')[0]);
    notes = json['notes'];
  }

  Map<String, String> toJson() {
    return {
      'name': name,
      'assignment_type': assignmentType,
      'date': date.toString(),
      'due_date': dueDate.toString(),
      'achieved_score': achievedScore.toString(),
      'max_score': maxScore.toString(),
      'achieved_points': achievedPoints.toString(),
      'max_points': maxPoints.toString(),
      'notes': notes
    };
  }
}

class Breakdown {
  List<Weighting> weightings;

  List<DataColumn> getDataColumns() {
    return <DataColumn>[
      DataColumn(
          label: const Text("Assignment\nType"),
          onSort: (final int index, final bool sort) {}),
      DataColumn(
          label: const Text("Average"),
          onSort: (final int index, final bool sort) {}),
      // DataColumn(
      //   label: const Text("Points")
      // ),
      DataColumn(
          label: const Text("Weight"),
          onSort: (final int index, final bool sort) {}),
      DataColumn(
          label: const Text("Letter\nGrade"),
          onSort: (final int index, final bool sort) {})
    ];
  }

  DataRow getDataRow(final int index) {
    assert(index >= 0);
    final weighting = weightings[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${weighting.name}'), onTap: () {}),
      DataCell(Text('${weighting.percentage}%'), onTap: () {}),
      DataCell(Text('${weighting.weight}%'), onTap: () {}),
      // DataCell(Text('${weighting.achievedPoints}/${weighting.maxPoints}')),
      DataCell(Text('${weighting.letterGrade}'), onTap: () {})
    ]);
  }

  List<DataRow> getDataRows() {
    List<DataRow> out = new List<DataRow>(weightings.length);
    for (int i = 0; i < weightings.length; i++) {
      out[i] = getDataRow(i);
    }
    return out;
  }
}

class Course {
  final int period;
  final String name;
  final String id;
  final String location;
  final String letterGrade;
  final double percentage;
  List<Assignment> assignments;
  final String teacher;
  Breakdown breakdown;

  Course(
      final String period,
      final String name,
      final String id,
      final String location,
      final String letterGrade,
      final String percentage,
      final String teacher)
      : period = int.parse(period),
        name = name,
        id = id,
        location = location,
        letterGrade = letterGrade,
        percentage = double.parse(percentage),
        teacher = teacher;

  Course.fromJson(final Map<String, dynamic> json)
      : period = json['period'],
        name = json['name']
            .substring(0, json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
            .trim(),
        id = json['name']
            .substring(json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
            .trim(),
        location = json['location'],
        letterGrade = json['grades']['third_quarter']['letter'], //TODO
        percentage =
            double.parse(json['grades']['third_quarter']['percentage']), //TODO
        teacher = json['teacher'] {
    assignments = <Assignment>[];
    breakdown = Breakdown();
    breakdown.weightings = <Weighting>[];
    // period = json['period'];
    // name = json['name']
    //     .toString()
    //     .substring(0, json['name'].toString().indexOf(RegExp(r"\([0-9A-Z]+\)")))
    //     .trim();
    // id = json['name']
    //     .substring(json['name'].toString().indexOf(name) + name.length)
    //     .trim();
    // location = json['location'];
    // letterGrade = json['grades']['third_quarter']['letter'];
    // percentage = double.tryParse(json['grades']['third_quarter']['percentage']);
    // teacher = json['teacher'];
    json['assignments']
        .forEach((final f) => assignments.add(Assignment.fromJson(f)));
    json['grades']['third_quarter']['breakdown'].forEach((final k, final v) =>
        breakdown.weightings.add(Weighting.fromJson(k, v)));
    breakdown.weightings.sort((final Weighting a, final Weighting b) =>
        a.name == "TOTAL"
            ? double.maxFinite.toInt()
            : a.name.compareTo(b.name));
  }

  Map<String, String> toJson() {
    return null; //TODO
  }
}

class User {
  final String username;
  final String school;
  final int grade;
  final Image photo;
  List<Course> courses;
  //name

  User(final String username, final String school, final String grade,
      final String photo)
      : username = username,
        school = school,
        grade = int.parse(grade),
        photo = Image.memory(base64.decode(photo), scale: 0.6);

  User.fromJson(final Map<String, dynamic> json)
      : username = json['username'],
        school = json['school_name'],
        grade = json['grade'],
        photo = Image.memory(base64.decode(json['photo']), scale: 0.6);

  Map<String, String> toJson() {
    return {'username': username, 'school': school, 'grade': grade.toString()};
  }
}

class Weighting {
  final String name;
  final double weight;
  final String letterGrade;
  final double percentage;
  final double achievedPoints, maxPoints;

  Weighting(
      final String name,
      final String weight,
      final String letterGrade,
      final String percentage,
      final String achievedPoints,
      final String maxPoints)
      : name = name,
        weight = double.parse(weight),
        letterGrade = letterGrade,
        percentage = double.parse(percentage),
        achievedPoints = double.parse(achievedPoints),
        maxPoints = double.parse(maxPoints);

  Weighting.fromJson(final String name, final Map<String, dynamic> json)
      : name = name,
        weight = double.parse(json['weight']),
        letterGrade = json['letter_grade'],
        percentage = double.parse(json['percentage']),
        achievedPoints = double.parse(json['points'].replaceAll(',', '')),
        maxPoints = double.parse(json['points_possible'].replaceAll(',', ''));

  Map<String, String> toJson() {
    return {
      'name': name,
      'weight': weight.toString(),
      'letter_grade': letterGrade,
      'percentage': percentage.toString(),
      'achieved_points': achievedPoints.toString(),
      'max_points': maxPoints.toString()
    };
  }
}
