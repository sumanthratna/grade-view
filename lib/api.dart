import 'dart:async' show Future;
import 'dart:collection' show ListBase;
import 'dart:convert' show base64, base64Encode, utf8, jsonDecode;
import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:flutter/material.dart'
    show Text, Image, DataRow, DataColumn, DataCell, required;
import 'package:http/http.dart' as http show get, post;
import 'package:http/http.dart' show Response;

import 'globals.dart' show firebaseMessaging, storage;

int getMantissaLength(final String arg) =>
    arg != null ? (arg.length - arg.lastIndexOf(RegExp(r"\.")) - 1) : -1;

String convertPercentageToLetterGrade(final double percentage) {
  final int rounded = percentage.round();
  if (rounded >= 93) {
    return "A";
  } else if (90 <= rounded && rounded <= 92) {
    return "A-";
  } else if (87 <= rounded && rounded <= 89) {
    return "B+";
  } else if (83 <= rounded && rounded <= 86) {
    return "B";
  } else if (80 <= rounded && rounded <= 82) {
    return "B-";
  } else if (77 <= rounded && rounded <= 79) {
    return "C+";
  } else if (73 <= rounded && rounded <= 76) {
    return "C";
  } else if (70 <= rounded && rounded <= 72) {
    return "C-";
  } else if (67 <= rounded && rounded <= 69) {
    return "D+";
  } else if (64 <= rounded && rounded <= 66) {
    return "D";
  } else {
    return "F";
  }
}

class API {
  static const String _base = "https://sisapi.sites.tjhsst.edu";
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
    return jsonDecode(response.body)['active'] ?? false;
  }

  static Future<Response> getGrades(
      final String username, final String password) {
    final String url = _base + "/grades/?save_password";
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
      // 'device_id': await FlutterUdid.udid,
      'active': true,
      'type': (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : null))
    };
    final Response response =
        await http.post(url, headers: {'Authorization': auth}, body: device);
    return Future.value((response.statusCode / 100).floor() == 2);
  }

  static Future<bool> setActivationForDevice(
      final String username, final String password, final bool activate) async {
    final String registrationId =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final String url = _base + "/devices/" + registrationId;
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final String id = await storage.read(key: 'gradeviewfirebaseid') ??
        Random().nextInt(2 ^ 32).toString();
    await storage.write(key: 'gradeviewfirebaseid', value: id);
    final Map<String, String> params = {
      'id': id,
      'name': 'FCPS GradeView notifications',
      'registration_id': registrationId,
      'device_id': '',
      // 'device_id': await FlutterUdid.udid,
      'active': activate.toString(),
      'type': (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : null))
    };
    final Response response =
        await http.post(url, headers: {'Authorizaton': auth}, body: params);
    print(params);
    print(response.statusCode);
    return Future.value((response.statusCode / 100).floor() == 2);
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
  bool real = true;

  Assignment(
      {@required final this.name,
      @required final this.assignmentType,
      @required final this.date,
      @required final this.dueDate,
      @required final this.achievedScore,
      @required final this.maxScore,
      @required final this.achievedPoints,
      @required final this.maxPoints,
      @required final this.notes,
      final this.real});

  Assignment.fromJson(final Map<String, dynamic> json)
      : name = json['name'],
        assignmentType = json['assignment_type'],
        notes = json['notes'],
        date = DateTime.parse(json['date']),
        dueDate = DateTime.parse(json['due_date']) {
    final score = json['score'].split(' out of ');
    achievedScore = double.tryParse(score[0]);
    maxScore = double.tryParse(score[score.length == 2 ? 1 : 0]);
    final points = json['points'].split(' / ');
    achievedPoints = double.tryParse(points[0]);
    maxPoints = double.tryParse(
        points.length == 2 ? points[1] : points[0].split(' ')[0]);
  }

  Map<String, String> toJson() => {
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

  String toString() => toJson().toString();
}

class Breakdown extends ListBase<Weighting> {
  List<Weighting> weightings;

  Breakdown() : weightings = <Weighting>[];

  int get length => weightings.length;
  set length(final int length) => weightings.length = length;
  Weighting operator [](final dynamic arg) {
    if (arg is int) {
      // The argument is an index.
      return weightings[arg];
    } else if (arg is String) {
      // The argument is the name of the desired [Weighting].
      // Creates map-like behavior.
      return weightings[
          weightings.map((final Weighting f) => f.name).toList().indexOf(arg)];
    } else {
      return null;
    }
  }

  void operator []=(final int index, final Weighting value) =>
      weightings[index] = value;

  void add(final Weighting value) => weightings.add(value);
  void addAll(final Iterable<Weighting> all) => weightings.addAll(all);

  List<DataColumn> getDataColumns() => <DataColumn>[
        DataColumn(
            label: const Text("Assignment\nType"),
            onSort: (final int index, final bool sort) {}),
        DataColumn(
            label: const Text("Average"),
            onSort: (final int index, final bool sort) {}),
        DataColumn(
            label: const Text("Weight"),
            onSort: (final int index, final bool sort) {}),
        DataColumn(label: const Text("Points")),
        DataColumn(
            label: const Text("Letter\nGrade"),
            onSort: (final int index, final bool sort) {})
      ];

  DataRow getDataRow(final int index) {
    assert(index >= 0);
    final weighting = weightings[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${weighting.name}'), onTap: () {}),
      DataCell(Text('${weighting.percentage.toInt()}%'), onTap: () {}),
      DataCell(Text('${weighting.weight}%'), onTap: () {}),
      DataCell(Text('${weighting.achievedPoints}/${weighting.maxPoints}')),
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

  Map<String, double> toJson() {
    Map<String, double> out = Map<String, double>();
    for (final Weighting weighting in weightings) {
      out[weighting.name] = weighting.percentage;
    }
    return out;
  }

  String toString() => toJson().toString();
}

class Course {
  final int period;
  final String name;
  final String id;
  final String location;
  String letterGrade;
  double percentage;
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
        percentage = double.parse(percentage),
        courseMantissaLength = getMantissaLength(percentage.toString());

  Course.fromJson(final Map<String, dynamic> json)
      : period = json['period'],
        name = json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")) >= 0
            ? json['name']
                .substring(0, json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
                .trim()
            : json['name'],
        id = json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")) >= 0
            ? json['name']
                .substring(json['name'].indexOf(RegExp(r"\([0-9A-Z]+\)")))
                .trim()
            : null,
        location = json['location'],
        letterGrade = json['grades'] != null
            ? json['grades'][json['grades']?.keys?.first]['letter']
            : null,
        percentage = json['grades'] != null
            ? double.tryParse(
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
      breakdown.sort((final Weighting a, final Weighting b) => a.name == "TOTAL"
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

class Weighting {
  final String name;
  final double weight;
  String letterGrade;
  double percentage;
  double achievedPoints, maxPoints;
  final int weightingMantissaLength;

  Weighting(
      {@required final this.name,
      @required final String weight,
      @required final this.letterGrade,
      @required final String percentage,
      @required final String achievedPoints,
      @required final String maxPoints})
      : weight = double.parse(weight),
        percentage = double.parse(percentage),
        achievedPoints = double.parse(achievedPoints),
        maxPoints = double.parse(maxPoints),
        weightingMantissaLength = getMantissaLength(percentage);

  Weighting.fromJson(final String name, final Map<String, dynamic> json)
      : name = name,
        weight = double.parse(json['weight']),
        letterGrade = json['letter_grade'],
        percentage = double.parse(json['percentage']),
        achievedPoints = double.parse(json['points'].replaceAll(',', '')),
        maxPoints = double.parse(json['points_possible'].replaceAll(',', '')),
        weightingMantissaLength = getMantissaLength(json['percentage']);

  Map<String, String> toJson() => {
        'name': name,
        'weight': weight.toString(),
        'letter_grade': letterGrade,
        'percentage': percentage.toString(),
        'achieved_points': achievedPoints.toString(),
        'max_points': maxPoints.toString()
      };

  String toString() => toJson().toString();
}
