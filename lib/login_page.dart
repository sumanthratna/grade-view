import 'dart:convert' show jsonDecode;
import 'dart:io' show SocketException;

import 'package:flutter/material.dart';
import 'package:grade_view/api.dart' show API, User;
import 'package:grade_view/home_page.dart' show HomePage;

import 'exceptions.dart';
import 'globals.dart';

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final bool autofocus;
  final bool obscureText;
  final String helpText;
  const InputText(
      {@required final Key key,
      @required final this.controller,
      @required final this.inputType,
      @required final this.obscureText,
      @required final this.helpText,
      @required final this.autofocus})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: inputType,
      autofocus: autofocus,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: helpText,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  static const String tag = 'login-page';
  static const SnackBar incorrectCredentials = const SnackBar(
      content: const Text('Incorrect Username or Password'),
      duration: const Duration(seconds: 5));
  static const SnackBar noInternet = const SnackBar(
      content: const Text('No Internet Connection'),
      duration: const Duration(seconds: 10));
  static const SnackBar enterUsername = const SnackBar(
          content: const Text('Please Enter a Username'),
          duration: const Duration(seconds: 5)),
      enterPassword = const SnackBar(
          content: const Text('Please Enter a Password'),
          duration: const Duration(seconds: 5)),
      enterBoth = const SnackBar(
          content: const Text('Please Enter a Username and Password'),
          duration: const Duration(seconds: 5));
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _usernameController = TextEditingController(),
      _passwordController = TextEditingController();

  @override
  Widget build(final BuildContext context) {
    final logo = Hero(
      tag: 'logo',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final username = InputText(
        key: const Key('username'),
        controller: _usernameController,
        inputType: TextInputType.number,
        autofocus: true,
        obscureText: false,
        helpText: 'Username');

    final password = InputText(
        key: const Key('password'),
        controller: _passwordController,
        inputType: TextInputType.text,
        autofocus: false,
        obscureText: true,
        helpText: 'Password');

    final loginButton = Padding(
        key: const Key('log in'),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  throw NoUsernameException();
                } else if (usernameInput.isNotEmpty && passwordInput.isEmpty) {
                  throw NoPasswordException();
                } else if (usernameInput.isEmpty && passwordInput.isEmpty) {
                  throw NoCredentialsException();
                }
                final response =
                    await API.getUser(usernameInput, passwordInput);
                print('status code ' + response.statusCode.toString());
                if ((response.statusCode / 100).floor() == 2) {
                  user = User.fromJson(jsonDecode(response.body));
                  storage.write(key: "password", value: passwordInput);
                  _scaffoldKey.currentState.removeCurrentSnackBar();
                  Navigator.of(context).pushNamed(HomePage.tag);
                  /* Navigator.of(context).pushNamedAndRemoveUntil(
                      HomePage.tag, ModalRoute.withName(HomePage.tag));*/
                } else {
                  if ((response.statusCode / 100).floor() == 4) {
                    throw IncorrectCredentialsException();
                  } else {
                    //triggers the else in the catch
                    throw Exception('Status Code ' + response.statusCode);
                  }
                }
              } catch (e) {
                if (e is NoUsernameException) {
                  showSnackBar(enterUsername);
                } else if (e is NoPasswordException) {
                  showSnackBar(enterPassword);
                } else if (e is NoCredentialsException) {
                  showSnackBar(enterBoth);
                } else if (e is IncorrectCredentialsException) {
                  showSnackBar(incorrectCredentials);
                } else if (e is SocketException) {
                  showSnackBar(noInternet);
                } else {
                  showSnackBar(e);
                }
              }
            },
            padding: const EdgeInsets.all(12),
            color: Colors.lightBlueAccent,
            child: const Text('Log In',
                style: const TextStyle(color: Colors.white))));

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Center(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
              logo,
              const SizedBox(height: 48.0),
              username,
              const SizedBox(height: 8.0),
              password,
              const SizedBox(height: 24.0),
              loginButton,
              // const SizedBox(height: 180.0)
            ])));
  }

  showSnackBar(final SnackBar arg) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(arg);
  }

  showSnackbar(final Exception e) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Unexpected Error (" + e.toString() + ")"),
        duration: const Duration(seconds: 10)));
  }
}
