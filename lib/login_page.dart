import 'package:flutter/material.dart';
import 'package:grade_view/home_page.dart';
import 'package:grade_view/api.dart';
import 'dart:convert'; //base64
import 'globals.dart' as globals;
import 'dart:io'; //socketexception

class LoginPage extends StatelessWidget {
  static const String tag = 'login-page';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar incorrectPassword = SnackBar(content: Text('Incorrect Username or Password'), duration: Duration(seconds: 10));
  final SnackBar noInternet = SnackBar(content: Text('No Internet Connection'), duration: Duration(seconds: 10));
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  showSnackBar(SnackBar arg) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(arg);
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final username = TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.number,
      autofocus: true,
      // initialValue: 'username',
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: _passwordController,
      autofocus: false,
      // initialValue: 'weakpass',
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          final String usernameInput=_usernameController.text.trim(), passwordInput=_passwordController.text.trim();
          // final String auth = 'Basic ' + base64Encode(utf8.encode('$username_input:$password_input'));
            API.getUser(usernameInput, passwordInput).then((response) {
              print('status code '+response.statusCode.toString());
              if ((response.statusCode/100).floor()==2) { //2xx status code
                globals.user = globals.User.fromJson(jsonDecode(response.body));

                // globals.storage.write(key: "username", value: _usernameController.text);
                globals.storage.write(key: "password", value: _passwordController.text);
                Navigator.of(context).pushNamed(HomePage.tag);
              }
              else {
                throw(globals.IncorrectPasswordException);
                // showSnackBar(incorrectPassword);
              }
            })
            .catchError(showSnackBar(incorrectPassword), test: (e) => e is globals.IncorrectPasswordException)
            .catchError(showSnackBar(noInternet), test: (e) => e is SocketException);
          // final /*Future<http.Response>*/ response = await http.get('https://sisapi.sites.tjhsst.edu/user/', headers: {'Authorization': auth});
          // print(response.statusCode); //TODO: fix
          // print('logging in $username_input with $password_input');
          // Navigator.of(context).pushNamed(HomePage.tag);
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );
/*
    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );*/

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            username,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton
            //forgotLabel
          ],
        ),
      ),
    );
  }
}
