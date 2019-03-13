import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:grade_view/api.dart' show API, Course;

import 'api.dart';
import 'course_page.dart' show CoursePage;
import 'custom_widgets.dart' show Info;
import 'globals.dart' show user, storage;

class HomePage extends StatefulWidget {
  static const String tag = 'home-page';

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<HomePage> {
  int _currentIndex = 0; //for bottom navigation
  bool _active = false; //for device

  final List<Widget> _screens = <Widget>[];
  @override
  Widget build(final BuildContext context) {
    if (user.courses == null || user.courses.isEmpty) {
      return const Center(child: const CircularProgressIndicator());
    }

    final img = Hero(
        tag: 'img',
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                child: user.photo,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 8.0)))));

    final welcome = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        user.username,
        style: const TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final school = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        user.school,
        style: const TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );

    final classes = ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: user.courses.length,
      itemBuilder: (final BuildContext context, final int index) {
        return Container(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: user.courses[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: " " + user.courses[index].id,
                  style: const TextStyle(fontWeight: FontWeight.normal)),
            ], style: const TextStyle(fontSize: 16.0, color: Colors.white)))));
      },
    );

    final userScreen = Container(
      key: const Key('base'),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: const BoxDecoration(
        gradient: const LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),
      child: Column(
        children: <Widget>[img, welcome, school, Expanded(child: classes)],
      ),
    );

    final grades = ListView.builder(
        itemCount: user.courses.length,
        itemBuilder: (final BuildContext context, final int index) {
          return Info(
              left: user.courses[index].name,
              right: user.courses[index].letterGrade +
                  " (" +
                  user.courses[index].percentage.toString() +
                  ")",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (final context) =>
                            CoursePage(course: user.courses[index])));
              });
        });

    final gradesScreen = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: const BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent])),
      child: Column(children: <Widget>[
        const Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 5.0),
            child: const Text("Grades",
                style: const TextStyle(fontSize: 32.0, color: Colors.white))),
        Expanded(child: grades)
      ]),
    );

    final settings = SwitchListTile(
        title: const Text("Enable push notifications",
            style: const TextStyle(color: Colors.white)),
        value: _active,
        onChanged: (final bool newValue) async {
          if (newValue) {
            await API.registerDevice(
                user.username, await storage.read(key: 'gradeviewpassword'));
          } else {
            await API.setActivationForDevice(user.username,
                await storage.read(key: 'gradeviewpassword'), false);
          }
        });

    final settingsScreen = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: const BoxDecoration(
            gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent])),
        child: Column(children: <Widget>[
          const Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 5.0),
              child: const Text("Settings",
                  style: const TextStyle(fontSize: 32.0, color: Colors.white))),
          settings
        ]));

    _screens.add(userScreen);
    _screens.add(gradesScreen);
    _screens.add(settingsScreen);

    final navBar = BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: navigate,
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
              icon: const Icon(Icons.person), title: const Text('Home')),
          const BottomNavigationBarItem(
              icon: const Icon(Icons.school), title: const Text('Grades')),
          // const BottomNavigationBarItem(
          // icon: const Icon(Icons.show_chart), title: const Text('Charts')),
          const BottomNavigationBarItem(
              icon: const Icon(Icons.settings), title: const Text('Settings'))
        ]);

    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
              child: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
              }),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: false),
      body: _screens[_currentIndex],
      bottomNavigationBar: navBar,
    );
  }

  void fetchActive() async {
    _active = await API.getActivationForDevice(
        user.username, await storage.read(key: 'gradeviewpassword'));
  }

  void fetchUser() async {
    user.courses = [];
    final courses = jsonDecode((await API.getGrades(
            user.username, await storage.read(key: 'gradeviewpassword')))
        .body)['courses'];
    courses.forEach(
        (f) => user.courses.add(Course.fromJson(f as Map<String, dynamic>)));
    setState(() {});
    //cache grades
    await storage.delete(key: 'gradeviewpassword');
  }

  @protected
  @mustCallSuper
  @override
  void initState() {
    fetchUser();
    fetchActive();
    super.initState();
  }

  void navigate(final int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
