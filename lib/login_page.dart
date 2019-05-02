import 'dart:convert' show jsonDecode;
import 'dart:io' show HttpStatus, SocketException;

import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        SnackBar,
        Text,
        GlobalKey,
        ScaffoldState,
        TextEditingController,
        Widget,
        BuildContext,
        Hero,
        CircleAvatar,
        Colors,
        Image,
        Key,
        TextInputType,
        Padding,
        EdgeInsets,
        RaisedButton,
        RoundedRectangleBorder,
        BorderRadius,
        Navigator,
        MaterialPageRoute,
        TextStyle,
        Scaffold,
        Center,
        ListView,
        SizedBox,
        protected,
        mustCallSuper;
import 'package:grade_view/api.dart' show API, User;
import 'package:grade_view/home_page.dart' show HomePage;
import 'package:http/http.dart' show Response;
import 'package:modal_progress_hud/modal_progress_hud.dart'
    show ModalProgressHUD;

import 'custom_exceptions.dart';
import 'custom_widgets.dart' show InputText;
import 'globals.dart' show user, storage, testUsername;

class LoginPage extends StatefulWidget {
  static const String tag = '/';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const SnackBar enterUsername = SnackBar(
          content: Text('Please Enter a Username'),
          duration: Duration(seconds: 5)),
      enterPassword = SnackBar(
          content: Text('Please Enter a Password'),
          duration: Duration(seconds: 5)),
      enterBoth = SnackBar(
          content: Text('Please Enter a Username and Password'),
          duration: Duration(seconds: 5)),
      incorrectCredentials = SnackBar(
          content: Text('Incorrect Username or Password'),
          duration: Duration(seconds: 5)),
      noInternet = SnackBar(
          content: Text('No Internet Connection'),
          duration: Duration(seconds: 10));
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController(),
      _passwordController = TextEditingController();
  bool _loginButtonEnabled = true;
  bool _loading = false;

  @override
  Widget build(final BuildContext context) {
    final Widget logo = Hero(
      tag: 'logo',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/fcps.png'),
      ),
    );

    final Widget username = InputText(
        key: const Key('username'),
        controller: _usernameController,
        keyboardType: TextInputType.number,
        autofocus: true,
        obscureText: false,
        helpText: 'Username',
        enabled: !_loading);

    final Widget password = InputText(
        key: const Key('password'),
        controller: _passwordController,
        keyboardType: TextInputType.text,
        autofocus: false,
        obscureText: true,
        helpText: 'Password',
        enabled: !_loading);

    final Widget loginButton = Padding(
        key: const Key('log-in'),
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
        if (response.statusCode == HttpStatus.ok) {
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
            onPressed: _loginButtonEnabled
                ? () async {
                    setState(() {
                      _loginButtonEnabled = false;
                      _loading = true;
                    });
                    try {
                      final String usernameInput =
                              _usernameController.text.trim(),
                          passwordInput = _passwordController.text.trim();
                      if (usernameInput.isEmpty && passwordInput.isNotEmpty) {
                        throw NoUsernameException();
                      } else if (usernameInput.isNotEmpty &&
                          passwordInput.isEmpty &&
                          usernameInput != testUsername) {
                        throw NoPasswordException();
                      } else if (usernameInput.isEmpty &&
                          passwordInput.isEmpty) {
                        throw NoCredentialsException();
                      }
                      final Response response =
                          await API.getUser(usernameInput, passwordInput);
                      print('status code ' + response.statusCode.toString());
                      if (response.statusCode == HttpStatus.ok) {
                        user = User.fromJson(jsonDecode(response.body));
                        storage.write(
                            key: "gradeviewpassword", value: passwordInput);
                        _scaffoldKey.currentState.removeCurrentSnackBar();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final BuildContext context) =>
                                    HomePage())).then((final dynamic onValue) {
                          setState(() {
                            _loginButtonEnabled = true;
                            _loading = false;
                          });
                        });
                      } else {
                        if (response.statusCode == HttpStatus.forbidden ||
                            response.statusCode == HttpStatus.unauthorized) {
                          throw IncorrectCredentialsException();
                        } else {
                          // Triggers the `else` in the `catch`.
                          throw Exception(
                              'Status Code ' + response.statusCode.toString());
                        }
                      }
                    } catch (e) {
                      // TODO: Change to
                      // ```dart
                      // on NoUsernameException catch(e) {
                      //   //...
                      // }
                      // //...
                      // ```
                      // Not implemented yet since it originally seemed like there were performance issues.
                      // Benchmark both syntaxes to find out if one way is slower than the other.
                      print(e);
                      setState(() {
                        _loginButtonEnabled = true;
                        _loading = false;
                      });
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
                  }
                : null,
            padding: const EdgeInsets.all(12),
            color: Colors.lightBlueAccent,
            child:
                const Text('Log In', style: TextStyle(color: Colors.white))));

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
            child: Center(
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
                ])),
            inAsyncCall: _loading));
  }

  @protected
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    setState(() => _loginButtonEnabled = true);
  }

  void showSnackBar(final dynamic arg) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    if (arg is SnackBar) {
      _scaffoldKey.currentState.showSnackBar(arg);
    } else if (arg is Exception) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(arg.toString()),
          duration: const Duration(seconds: 10)));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(arg.toString()),
          duration: const Duration(seconds: 10)));
    }
  }
}
