import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging;

import 'api.dart' show User;

final FlutterSecureStorage storage = FlutterSecureStorage();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging()
  ..requestNotificationPermissions()
  ..configure();
User user;
