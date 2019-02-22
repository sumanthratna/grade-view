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
  final String helpText;
  const InputText(
      {@required Key key,
      @required this.controller,
      @required this.inputType,
      @required this.helpText,
      @required this.autofocus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: this.key,
      controller: this.controller,
      keyboardType: this.inputType,
      autofocus: true,
      decoration: InputDecoration(
        hintText: this.helpText,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  static const String tag = 'login-page';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar incorrectPassword = const SnackBar(
      content: const Text('Incorrect Username or Password'),
      duration: const Duration(seconds: 5));
  final SnackBar noInternet = const SnackBar(
      content: const Text('No Internet Connection'),
      duration: const Duration(seconds: 10));
  final SnackBar enterUsername = const SnackBar(
          content: const Text('Please Enter a Username'),
          duration: const Duration(seconds: 5)),
      enterPassword = const SnackBar(
          content: const Text('Please Enter a Password'),
          duration: const Duration(seconds: 5)),
      enterBoth = const SnackBar(
          content: const Text('Please Enter a Username and Password'),
          duration: const Duration(seconds: 5));
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
        helpText: 'Username');

    final password = InputText(
        key: const Key('password'),
        controller: _passwordController,
        inputType: TextInputType.text,
        autofocus: false,
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
                }
                if (usernameInput.isNotEmpty && passwordInput.isEmpty) {
                  throw NoPasswordException();
                }
                if (passwordInput.isEmpty) {
                  throw NoCredentialsException();
                }
                final response =
                    await API.getUser(usernameInput, passwordInput);
                print('status code ' + response.statusCode.toString());
                if ((response.statusCode / 100).floor() == 2) {
                  //response.statusCode.toString().startsWith('2')
                  user = User.fromJson(jsonDecode(response.body));
                  storage.write(key: "password", value: passwordInput);
                  _scaffoldKey.currentState.removeCurrentSnackBar();
                  Navigator.of(context).pushNamed(HomePage.tag);
                  /* Navigator.of(context).pushNamedAndRemoveUntil(
                      HomePage.tag, ModalRoute.withName(HomePage.tag));*/
                } else {
                  throw IncorrectCredentialsException();
                }
              } catch (e) {
                if (e is NoUsernameException) {
                  showSnackBar(enterUsername);
                } else if (e is NoPasswordException) {
                  showSnackBar(enterPassword);
                } else if (e is NoCredentialsException) {
                  showSnackBar(enterBoth);
                } else if (e is IncorrectCredentialsException) {
                  showSnackBar(incorrectPassword);
                } else if (e is SocketException) {
                  showSnackBar(noInternet);
                } else {
                  showSnackBar(e);
                }
              }
            },
            padding: const EdgeInsets.all(12),
            color: Colors.lightBlueAccent,
            child:
                const Text('Log In', style: TextStyle(color: Colors.white))));

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
              loginButton
            ])));
  }

  showSnackBar(SnackBar arg) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(arg);
  }

  showSnackbar(Exception e) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Unexpected Error (" + e.toString() + ")")));
  }
}
