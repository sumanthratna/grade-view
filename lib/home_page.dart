import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';

import 'api.dart' show API, Course;
import 'course_page.dart' show CoursePage;
import 'custom_widgets.dart' show LogoutBar, LoadingIndicator, Info;
import 'globals.dart' show user, storage, decoration;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; //for bottom navigation
  bool _firebaseDeviceActive = false; //for device

  final List<Widget> _screens = <Widget>[];

  @override
  Widget build(final BuildContext context) {
    if (user.courses == null || user.courses.isEmpty) {
      return const LoadingIndicator();
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
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white),
                        children: <TextSpan>[
                  TextSpan(
                      text: user.courses[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: " " + user.courses[index].id,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                ]))));
      },
    );

    final userScreen = Container(
      key: const Key('base'),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
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
                        settings: RouteSettings(name: 'course-page'),
                        builder: (final BuildContext context) =>
                            CoursePage(course: user.courses[index])));
              });
        });

    final gradesScreen = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
      child: Column(children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 5.0),
            child: Text("Grades",
                style: TextStyle(fontSize: 32.0, color: Colors.white))),
        Expanded(child: grades)
      ]),
    );

    final settings = SwitchListTile(
        title: const Text("Enable push notifications",
            style: TextStyle(color: Colors.white)),
        value: _firebaseDeviceActive,
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
        decoration: decoration,
        child: Column(children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(top: 40.0, bottom: 5.0),
              child: Text("Settings",
                  style: TextStyle(fontSize: 32.0, color: Colors.white))),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.school), title: Text('Grades')),
          // const BottomNavigationBarItem(
          // icon: const Icon(Icons.show_chart), title: const Text('Charts')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('Settings'))
        ]);

    return Scaffold(
      appBar: LogoutBar(
          appBar: AppBar(
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: false),
          onTap: () {
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
          }),
      body: _screens[_currentIndex],
      bottomNavigationBar: navBar,
    );
  }

  void fetchActive() async {
    _firebaseDeviceActive = await API.getActivationForDevice(
        user.username, await storage.read(key: 'gradeviewpassword'));
  }

  void fetchUser() async {
    final unparsed = jsonDecode((await API.getGrades(
            user.username, await storage.read(key: 'gradeviewpassword')))
        .body)['courses'];
    user.courses = [];
    unparsed.forEach((final f) =>
        user.courses.add(Course.fromJson(f as Map<String, dynamic>)));
    setState(() => user.courses = List<Course>.from(user.courses));
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

  void refreshUserCoursesList() =>
      setState(() => user.courses = List<Course>.from(user.courses));
}
