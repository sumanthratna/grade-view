library grade_view.globals;

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

class Course {
  int period;
  String name;
  String location;
  String letterGrade; double percentage;
  List<Assignment> assignments;
  String teacher;

  Course.fromJson(Map json) {
    this.assignments = [];
    this.period = json['period'];
    this.name = json['name'];
    this.location = json['location'];
    this.letterGrade = json['grades']['third_quarter']['letter'];
    this.percentage = double.tryParse(json['grades']['third_quarter']['percentage']);
    this.teacher = json['teacher'];
    json['assignments'].forEach((f) => this.assignments.add(Assignment.fromJson(f)));
    // json.forEach((grade) => (this.grades.add(Assignment.fromJson(grade))));
    // json.forEach((name,assignmentType,date) => Assignment.fromJson());
  }
}

class IncorrectPasswordException implements Exception {
  String toString() {
    return "Incorrect Password";
  }
}

const String api = "https://sisapi.sites.tjhsst.edu";
final storage = FlutterSecureStorage();
User user;
