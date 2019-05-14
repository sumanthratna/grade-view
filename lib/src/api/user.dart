import 'dart:convert' show base64;

import 'package:flutter/material.dart' show Image, required;
import 'package:grade_view/api.dart' show Course;

class User {
  final String name;
  final String username;
  final String school;

  /// The grade level.
  final int grade;
  final Image photo;
  List<Course> courses;

  User(
      {@required final this.name,
      @required final this.username,
      @required final this.school,
      @required final String grade,
      @required final String photo})
      : grade = int.parse(grade),
        photo = Image.memory(base64.decode(photo), scale: 0.6);

  User.fromJson(final Map<String, dynamic> json)
      : name = json['full_name'],
        username = json['username'],
        school = json['school_name'],
        grade = json['grade'],
        photo = Image.memory(base64.decode(json['photo']), scale: 0.6),
        courses = <Course>[] {
    /*
    (json['schedule'] as List<dynamic>).forEach((final dynamic f) =>
        courses.add(Course.fromJson(f as Map<String, dynamic>)));
        */
  }

  Map<String, String> toJson() =>
      {'username': username, 'school': school, 'grade': grade.toString()};

  String toString() => toJson().toString();
}
