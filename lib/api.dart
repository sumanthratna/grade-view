import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

class API {
  static Future getUser(String username, String password) {
    final String url = globals.api + "/user/";
    final String auth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }
  static Future getGrades(String username, String password) {
    final String url = globals.api + "/grades/";
    final String auth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {'Authorization': auth});
  }
}
