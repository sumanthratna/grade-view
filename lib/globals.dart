import 'package:flutter/material.dart'
    show BoxDecoration, Colors, LinearGradient;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;

import 'package:grade_view/api.dart' show User;

const BoxDecoration decoration = BoxDecoration(
    gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]));
const String testUsername = '1234567';
final FlutterSecureStorage storage = FlutterSecureStorage();
User user;
