import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grade_view/api.dart';
import 'package:grade_view/home_page.dart';

import 'globals.dart';

import 'exceptions.dart';

class LoginPage extends StatelessWidget {
  static const String tag = 'login-page';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar incorrectPassword = SnackBar(
    content: Text('Incorrect Username or Password'),
    duration: Duration(seconds: 5));
  final SnackBar noInternet = SnackBar(
    content: Text('No Internet Connection'), duration: Duration(seconds: 10));
  final SnackBar
  enterUsername = SnackBar(
    content: Text('Please Enter a Username'), duration: Duration(seconds: 5)),
  enterPassword = SnackBar(
    content: Text('Please Enter a Password'), duration: Duration(seconds: 5)),
  enterBoth = SnackBar(
    content: Text('Please Enter a Username and Password'), duration: Duration(seconds: 5));
  final _usernameController = TextEditingController(), _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  final logo = Hero(
    tag: 'logo',
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
    decoration: InputDecoration(
    hintText: 'Username',
    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    ),
  );

  final password = TextFormField(
    controller: _passwordController,
    autofocus: false,
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
    /* more idiomatic, but slower
    onPressed: () async {
      final String usernameInput = _usernameController.text.trim(),
          passwordInput = _passwordController.text.trim();
      try {
        final response =
            await API.getUser(usernameInput, passwordInput);
        print('status code ' + response.statusCode.toString());
        if ((response.statusCode / 100).floor() == 2) {
          //2xx status code
          user = User.fromJson(jsonDecode(response.body));
          storage.write(key: "password", value: passwordInput);
          Navigator.of(context).pushNamed(HomePage.tag);
        } else {
          throw (IncorrectPasswordException());
        }
      } on IncorrectPasswordException {
        showSnackBar(incorrectPassword);
      } on SocketException {
        showSnackBar(noInternet);
      } catch (e) {
        showSnackBar(SnackBar(
            content: Text('Encountered an Unexpected Error'),
            duration: Duration(seconds: 5)));
      }
    },
     */
    onPressed: () async {
      try {
        final String usernameInput = _usernameController.text.trim(),
          passwordInput = _passwordController.text.trim();
        if (usernameInput.isEmpty && passwordInput.isNotEmpty) {
          throw(NoUsernameException());
        }
        if (usernameInput.isNotEmpty && passwordInput.isEmpty) {
          throw(NoPasswordException());
        }
        if (passwordInput.isEmpty) {
          throw(NoCredentialsException());
        }
        final response = await API.getUser(usernameInput, passwordInput);
        print('status code ' + response.statusCode.toString());
        if ((response.statusCode / 100).floor() == 2) {
          //2xx status code
          user = User.fromJson(jsonDecode(response.body));
          storage.write(key: "password", value: passwordInput);
          Navigator.of(context).pushNamed(HomePage.tag);
        } else {
          throw (IncorrectCredentialsException());
        }
      } catch (e) {
        if (e is NoUsernameException) {
          showSnackBar(enterUsername);
        }
        else if (e is NoPasswordException) {
          showSnackBar(enterPassword);
        }
        else if (e is NoCredentialsException) {
          showSnackBar(enterBoth);
        }
        else if (e is IncorrectCredentialsException) {
          showSnackBar(incorrectPassword);
        }
        else if (e is SocketException) {
          showSnackBar(noInternet);
        }
      }
    },
    padding: EdgeInsets.all(12),
    color: Colors.lightBlueAccent,
    child: Text('Log In', style: TextStyle(color: Colors.white))
    )
  );

  return Scaffold(
    key: _scaffoldKey,
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
      ])));
  }

  showSnackBar(SnackBar arg) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(arg);
  }
}
