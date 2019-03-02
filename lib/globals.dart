import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;

import 'api.dart' show User;

final FirebaseMessaging firebaseMessaging = FirebaseMessaging()
  ..requestNotificationPermissions()
  ..configure();
final FlutterSecureStorage storage = FlutterSecureStorage();
User user;
