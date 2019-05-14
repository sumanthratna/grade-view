library api;

import 'dart:async' show Future;
import 'dart:convert' show base64Encode, utf8, jsonDecode;
import 'dart:io' show Platform, HttpStatus;
import 'dart:math' show Random, pow;

import 'package:decimal/decimal.dart' show Decimal;
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging;
import 'package:http/http.dart' as http show get, post, patch;
import 'package:http/http.dart' show Response;

import 'globals.dart' show storage;
import 'src/api/course.dart' show Course;

export 'src/api/assignment.dart' show Assignment;
export 'src/api/breakdown.dart' show Breakdown;
export 'src/api/course.dart' show Course;
export 'src/api/user.dart' show User;
export 'src/api/weighting.dart' show Weighting;

String convertPercentageToLetterGrade(final Decimal percentage) {
  if (percentage.isNaN || percentage.isInfinite) {
    return 'A';
  }
  final int rounded = percentage.round().toInt();
  if (rounded >= 93) {
    return 'A';
  } else if (90 <= rounded && rounded <= 92) {
    return 'A-';
  } else if (87 <= rounded && rounded <= 89) {
    return 'B+';
  } else if (83 <= rounded && rounded <= 86) {
    return 'B';
  } else if (80 <= rounded && rounded <= 82) {
    return 'B-';
  } else if (77 <= rounded && rounded <= 79) {
    return 'C+';
  } else if (73 <= rounded && rounded <= 76) {
    return 'C';
  } else if (70 <= rounded && rounded <= 72) {
    return 'C-';
  } else if (67 <= rounded && rounded <= 69) {
    return 'D+';
  } else if (64 <= rounded && rounded <= 66) {
    return 'D';
  } else {
    return 'F';
  }
}

int getMantissaLength(final String arg) =>
    arg != null ? (arg.length - arg.lastIndexOf(RegExp(r'\.')) - 1) : -1;

int setupAssignmentTypeSelector(final Course course) {
  if (course.assignments.isEmpty) {
    // There are no assignments yet.
    return -1;
  } else if (course.breakdown.isEmpty) {
    // There is no breakdown information, so all assignments are weighted equally.
    return 0;
  } else {
    // There are weighted assignments.
    return 1;
  }
}

class API {
  static const String _base = 'https://sisapi.sites.tjhsst.edu';
  static Future<bool> getActivationForDevice(
      final FirebaseMessaging firebaseMessaging,
      final String username,
      final String password) async {
    final String registrationID =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final String url = '$_base/devices/$registrationID/';
    // final String url = '$_base/devices/';
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final Response response =
        await http.get(Uri.encodeFull(url), headers: {'Authorization': auth});
    print('Firebase device: ${jsonDecode(response.body)['active']}');
    return jsonDecode(response.body)['active'];
  }

  static Future<Response> getGrades(
      final String username, final String password) {
    final String url = '$_base/grades/?save_password';
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future<Response> getUser(
      final String username, final String password) {
    final String url = '$_base/user/';
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }

  static Future<bool> registerDevice(final FirebaseMessaging firebaseMessaging,
      final String username, final String password) async {
    final String url = '$_base/devices/';
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final String registrationID =
        await storage.read(key: 'gradeviewfirebaseregistrationid') ??
            await firebaseMessaging.getToken();
    final Response check =
        await http.get(url, headers: {'Authorization': auth});
    if (check.body.contains(registrationID)) {
      return setActivationForDevice(
          firebaseMessaging, username, password, true);
    } else {
      await storage.write(
          key: 'gradeviewfirebaseregistrationid',
          value: await firebaseMessaging.getToken());
      final Map<String, String> device = {
        'id': Random().nextInt(pow(2, 32)).toString(),
        'name': 'FCPS GradeView notifications',
        'registration_id':
            await storage.read(key: 'gradeviewfirebaseregistrationid'),
        'device_id': '', //await FlutterUdid.udid,
        'active': true.toString(),
        'type':
            (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web'))
      };
      final Response response =
          await http.post(url, headers: {'Authorization': auth}, body: device);
      return Future.value(response.statusCode == HttpStatus.ok);
    }
  }

  static Future<bool> setActivationForDevice(
      final FirebaseMessaging firebaseMessaging,
      final String username,
      final String password,
      final bool activate) async {
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    Future<Map<String, String>> getParams() async {
      final String registrationId =
          await storage.read(key: 'gradeviewfirebaseregistrationid') ??
              await firebaseMessaging.getToken();
      return <String, String>{
        'registration_id': registrationId,
        'active': activate.toString(),
        'type':
            (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web'))
      };
    }

    final Map<String, String> params = await getParams();
    final String url = '$_base/devices/${params['registration_id']}';
    final Response response =
        await http.patch(url, headers: {'Authorizaton': auth}, body: params);
    print('Firebase device parameters: $params');
    return Future.value(response.statusCode == HttpStatus.ok);
  }
}
