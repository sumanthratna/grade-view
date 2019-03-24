import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'api.dart' show User;
import 'package:flutter/material.dart' show BoxDecoration, LinearGradient, Colors;

const decoration = BoxDecoration(
    gradient:
        LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]));
final FirebaseMessaging firebaseMessaging = FirebaseMessaging()
  ..requestNotificationPermissions()
  ..configure(onLaunch: (final Map<String, dynamic> message) {
    print('onLaunch called');
  }, onMessage: (final Map<String, dynamic> message) {
    print('onMessage called' + message.toString());
  }, onResume: (final Map<String, dynamic> message) {
    print('onResume called');
  });
final FlutterSecureStorage storage = FlutterSecureStorage();
User user;
