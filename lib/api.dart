import 'dart:async' show Future;
import 'dart:convert' show base64, base64Encode, utf8, jsonDecode;
import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:flutter/material.dart'
    show Text, Image, DataRow, DataColumn, DataCell;
// import 'package:device_id/device_id.dart' show DeviceId;
import 'package:http/http.dart' as http show get, post, put;
import 'package:http/http.dart' show Response;

import 'globals.dart' show firebaseMessaging, storage;

class API {
  static const String _base = "https://sisapi.sites.tjhsst.edu";
  static Future<Response> getGrades(
      final String username, final String password) {
    final String url = _base + "/grades/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future<Response> getUser(
      final String username, final String password) {
    final String url = _base + "/user/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future<bool> registerDevice(
      final String username, final String password) async {
    final String url = _base + "/devices/";
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final String registrationID =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final Response check =
        await http.get(url, headers: {'Authorization': auth});
    if (check.body.contains(registrationID)) {
      setActivationForDevice(username, password, true);
    }
    await storage.write(
        key: 'gradeviewfirebaseregistrationid',
        value: await firebaseMessaging.getToken());
    final Map<String, dynamic> device = {
      'id': Random()..nextInt(1000),
      'name': username,
      'registration_id':
          await storage.read(key: 'gradeviewfirebaseregistrationid'),
      'device_id': 4, //await DeviceId.getID,
      'active': true,
      'type': (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : null))
    };
    final Response response =
        await http.post(url, headers: {'Authorization': auth}, body: device);
    return ((response.statusCode / 100).floor() == 2);
  }

  static Future<bool> setActivationForDevice(
      final String username, final String password, final bool activate) async {
    final String registrationID =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final String url = _base + "/devices/" + registrationID;
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final Map<String, dynamic> params = {
      'registration_id': registrationID,
      'active': activate,
    };
    final Response response =
        await http.put(url, headers: {'Authorizaton': auth}, body: params);
    return ((response.statusCode / 100).floor() == 2);
  }

  static Future<bool> getActivationForDevice(
      final String username, final String password) async {
    final String registrationID =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final String url = _base + "/devices/" + registrationID;
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final Response response =
        await http.get(url, headers: {'Authorization': auth});
    return jsonDecode(response.body)['active'].toString() == 'true';
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
      final this.name,
      final this.assignmentType,
      final String date,
      final String dueDate,
      final String achievedScore,
      final String maxScore,
      final String achievedPoints,
      final String maxPoints,
      final this.notes)
      : date = DateTime.parse(date),
        dueDate = DateTime.parse(dueDate),
        achievedScore = double.parse(achievedScore),
        maxScore = double.parse(maxScore),
        achievedPoints = double.parse(achievedPoints),
        maxPoints = double.parse(maxPoints);

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
    List<DataRow> out = List<DataRow>(weightings.length);
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
      final this.name,
      final this.id,
      final this.location,
      final this.letterGrade,
      final String percentage,
      final this.teacher)
      : period = int.parse(period),
        percentage = double.parse(percentage);

  Course.fromJson(final Map<String, dynamic> json)
      : period = json['period'],
        name = json['name']
            .substring(0, json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
            .trim(),
        id = json['name']
            .substring(json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
            .trim(),
        location = json['location'],
        letterGrade =
            json['grades'][json['grades'].keys.first]['letter'], //TODO
        percentage = double.parse(
            json['grades'][json['grades'].keys.first]['percentage']), //TODO
        teacher = json['teacher'] {
    assignments = <Assignment>[];
    breakdown = Breakdown();
    breakdown.weightings = <Weighting>[];
    json['assignments']
        .forEach((final f) => assignments.add(Assignment.fromJson(f)));
    json['grades'][json['grades'].keys.first]['breakdown'].forEach(
        (final k, final v) =>
            breakdown.weightings.add(Weighting.fromJson(k, v)));
    breakdown.weightings.sort((final Weighting a, final Weighting b) =>
        a.name == "TOTAL"
            ? double.maxFinite.toInt()
            : a.name.compareTo(b.name));
  }

  Map<String, String> toJson() {
    return {
      'period': period.toString(),
      'name': name,
      'id': id,
      'location': location,
      'letterGrade': letterGrade,
      'percentage': percentage.toString(),
      'teacher': teacher
    };
  }
}

class User {
  final String username;
  final String school;
  final int grade;
  final Image photo;
  List<Course> courses;
  //name

  User(final this.username, final this.school, final grade, final String photo)
      : grade = int.parse(grade),
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
      final this.name,
      final String weight,
      final this.letterGrade,
      final String percentage,
      final String achievedPoints,
      final String maxPoints)
      : weight = double.parse(weight),
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
