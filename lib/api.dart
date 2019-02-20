import 'dart:convert' show base64, base64Encode, utf8;

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class User {
  String username;
  String school;
  int grade;
  Image photo;
  List<Course> courses;
  //name

  User(final String username, final String school, final int grade,
      final String photo)
      : this.username = username,
        this.school = school,
        this.grade = grade,
        this.photo = Image.memory(base64.decode(photo), scale: 0.6);

  User.fromJson(final Map json)
      : this.username = json['username'],
        this.school = json['school_name'],
        this.grade = json['grade'],
        this.photo = Image.memory(base64.decode(json['photo']), scale: 0.6);

  Map toJson() {
    return {'username': username, 'school': school, 'grade': grade};
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

  Assignment.fromJson(Map json) {
    this.name = json['name'];
    this.assignmentType = json['assignment_type'];
    this.date = DateTime.parse(json['date']);
    this.dueDate = DateTime.parse(json['due_date']);
    final score = json['score'].split(' out of ');
    this.achievedScore = double.tryParse(score[0]);
    this.maxScore = double.tryParse(score[score.length == 2 ? 1 : 0]);
    final points = json['points'].split(' / ');
    this.achievedPoints = double.tryParse(points[0]);
    this.maxPoints = double.tryParse(
        points.length == 2 ? points[1] : points[0].split(' ')[0]);
    this.notes = json['notes'];
  }
//     Map toJson() { //TODO
//       return {'name': };
//     }
}

class Weighting {
  String name;
  double weight;
  String letterGrade;
  double percentage;
  double achievedPoints;
  double maxPoints;

  Weighting.fromJson(String name, Map json)
      : this.name = name,
        this.weight = double.parse(json['weight']),
        this.letterGrade = json['letter_grade'],
        this.percentage = double.parse(json['percentage']),
        this.achievedPoints = double.parse(json['points'].replaceAll(',', '')),
        this.maxPoints =
            double.parse(json['points_possible'].replaceAll(',', ''));
}

class Breakdown {
  List<Weighting> weightings;

  Breakdown() : super();

  DataRow getDataRow(int index) {
    assert(index >= 0);
    final weighting = this.weightings[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${weighting.name}')),
      DataCell(Text('${weighting.weight}%')),
      // DataCell(Text('${weighting.achievedPoints}/${weighting.maxPoints}')),
      DataCell(Text('${weighting.percentage}%')),
      DataCell(Text('${weighting.letterGrade}'))
    ]);
  }

  List<DataRow> getDataRows() {
    List<DataRow> out = <DataRow>[];
    for (int i = 0; i < weightings.length; i++) {
      out.add(getDataRow(i));
    }
    return out;
  }

  List<DataColumn> getDataColumns() {
    return <DataColumn>[
      DataColumn(
          label: const Text("Assignment\nType"),
          onSort: (int index, bool sort) {}),
      DataColumn(
          label: const Text("Weight"), onSort: (int index, bool sort) {}),
      // DataColumn(
      //   label: const Text("Points")
      // ),
      DataColumn(
          label: const Text("Average"), onSort: (int index, bool sort) {}),
      DataColumn(
          label: const Text("Letter\nGrade"), onSort: (int index, bool sort) {})
    ];
  }
}

class Course {
  int period;
  String name;
  String id;
  String location;
  String letterGrade;
  double percentage;
  List<Assignment> assignments;
  String teacher;
  Breakdown breakdown;

  Course.fromJson(Map json) {
    this.assignments = <Assignment>[];
    this.breakdown = Breakdown();
    this.breakdown.weightings = <Weighting>[];
    this.period = json['period'];
    this.name = json['name']
        .toString()
        .substring(0, json['name'].toString().indexOf(RegExp(r"\([0-9A-Z]+\)")))
        .trim();
    this.id = json['name']
        .substring(
            json['name'].toString().indexOf(this.name) + this.name.length)
        .trim();
    this.location = json['location'];
    this.letterGrade = json['grades']['third_quarter']['letter'];
    this.percentage =
        double.tryParse(json['grades']['third_quarter']['percentage']);
    this.teacher = json['teacher'];
    json['assignments']
        .forEach((f) => this.assignments.add(Assignment.fromJson(f)));
    json['grades']['third_quarter']['breakdown'].forEach(
        (k, v) => this.breakdown.weightings.add(Weighting.fromJson(k, v)));
    this.breakdown.weightings.sort((Weighting a, Weighting b) =>
        a.name == "TOTAL"
            ? double.maxFinite.toInt()
            : a.name.compareTo(b.name));
  }
}

class API {
  static const String base = "https://sisapi.sites.tjhsst.edu";
  static Future getUser(String username, String password) {
    final String url = base + "/user/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future getGrades(String username, String password) {
    final String url = base + "/grades/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }
}
