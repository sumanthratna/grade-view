library grade_view.globals;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  String username;
  String school;
  int grade;
  String photo;
  List<Course> courses;
  //schedule
  //name

  User(String username, String school, int grade, String photo)
    : this.username = username,
      this.school = school,
      this.grade = grade,
      this.photo = photo;

  User.fromJson(Map json)
    : this.username = json['username'],
      this.school = json['school_name'],
      this.grade = json['grade'],
      this.photo = json['photo'];

  Map toJson() {
    return {'username': username, 'school': school, 'grade': grade, 'photo': photo};
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
    this.maxScore = double.tryParse(score[score.length==2 ? 1:0]);
    final points = json['points'].split(' / ');
    this.achievedPoints = double.tryParse(points[0]);
    this.maxPoints = double.tryParse(points.length==2 ? points[1]:points[0].split(' ')[0]);
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
  double achievedPoints; double maxPoints;

  Weighting.fromJson(String name, Map json)
    : this.name = name,
      this.weight = double.parse(json['weight']),
      this.letterGrade = json['letter_grade'],
      this.percentage = double.parse(json['percentage']),
      this.achievedPoints = double.parse(json['points'].replaceAll(',','')),
      this.maxPoints = double.parse(json['points_possible'].replaceAll(',',''));
}

class Breakdown {
  List<Weighting> weightings;

  Breakdown() : super();

  DataRow getDataRow(int index) {
    assert(index >= 0);
    final weighting = this.weightings[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${weighting.name}')),
        DataCell(Text('${weighting.weight}%')),
        // DataCell(Text('${weighting.achievedPoints}/${weighting.maxPoints}')),
        DataCell(Text('${weighting.percentage}%')),
        DataCell(Text('${weighting.letterGrade}'))
      ]
    );
  }
  List<DataRow> getDataRows() {
    List<DataRow> out = <DataRow>[];
    for (int i=0; i<weightings.length; i++) {
      out.add(getDataRow(i));
    }
    return out;
  }
  List<DataColumn> getDataColumns() {
    return <DataColumn>[
      DataColumn(
        label: const Text("Assignment\nType"),
        onSort: (int index, bool sort){}
      ),
      DataColumn(
        label: const Text("Weight"),
        onSort: (int index, bool sort){}
      ),
      // DataColumn(
      //   label: const Text("Points")
      // ),
      DataColumn(
        label: const Text("Average"),
        onSort: (int index, bool sort){}
      ),
      DataColumn(
        label: const Text("Letter\nGrade"),
        onSort: (int index, bool sort){}
      )
    ];
  }
}

class Course {
  int period;
  String name;
  String location;
  String letterGrade; double percentage;
  List<Assignment> assignments;
  String teacher;
  Breakdown breakdown;

  Course.fromJson(Map json) {
    this.assignments = <Assignment>[];
    this.breakdown = Breakdown();
    this.breakdown.weightings = <Weighting>[];
    this.period = json['period'];
    this.name = json['name'];
    this.location = json['location'];
    this.letterGrade = json['grades']['third_quarter']['letter'];
    this.percentage = double.tryParse(json['grades']['third_quarter']['percentage']);
    this.teacher = json['teacher'];
    json['assignments'].forEach((f) => this.assignments.add(Assignment.fromJson(f)));
    json['grades']['third_quarter']['breakdown'].forEach((k,v) => this.breakdown.weightings.add(Weighting.fromJson(k, v)));
    this.breakdown.weightings.sort((Weighting a, Weighting b) => a.name=="TOTAL" ? double.maxFinite.toInt():a.name.compareTo(b.name));
  }
}

const String api = "https://sisapi.sites.tjhsst.edu";
final storage = FlutterSecureStorage();
User user;
