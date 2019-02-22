import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart'
    show Swiper, SwiperPagination, SwiperControl;
import 'package:grade_view/api.dart' show API, Course;

import 'course_page.dart' show CoursePage;
import 'globals.dart';

class HomePage extends StatefulWidget {
  static const String tag = 'home-page';

  @override
  _MainState createState() => new _MainState();
}

class _MainState extends State<HomePage> {
  void init() async {
    final courses = jsonDecode((await API.getGrades(
            user.username, await storage.read(key: 'password')))
        .body)['courses'];
    user.courses = [];
    courses.forEach((f) => user.courses.add(Course.fromJson(f as Map)));
    //cache grades
    setState(() {});
  }

  @protected
  @mustCallSuper
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user.courses == null) {
      return Center(
          child: CircularProgressIndicator(backgroundColor: Colors.white));
    }

    final img = Hero(
        tag: 'img',
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
                child: user.photo,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 8.0)))));

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        user.username,
        style: TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final school = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        user.school,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );

    final classes = ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: user.courses.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: user.courses[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: " " + user.courses[index].id,
                  style: TextStyle(fontWeight: FontWeight.normal)),
            ], style: TextStyle(fontSize: 16.0, color: Colors.white)))));
      },
    );

    final home = Container(
      key: Key('base'),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),
      child: Column(
        children: <Widget>[img, welcome, school, Expanded(child: classes)],
      ),
    );

    final gradesContent = ListView.builder(
        itemCount: user.courses.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
              child: Card(
                  child: InkWell(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Align>[
                          Align(
                              child: RichText(
                                  text: TextSpan(
                                      text: user.courses[index].name,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                              alignment: Alignment.centerLeft),
                          Align(
                              child: RichText(
                                  text: TextSpan(
                                      text: user.courses[index].id,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black))),
                              alignment: Alignment.centerLeft),
                          Align(
                              child: RichText(
                                  text: TextSpan(
                                      text: user.courses[index].letterGrade +
                                          " (" +
                                          user.courses[index].percentage
                                              .toString() +
                                          ")",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black))),
                              alignment: Alignment.centerRight)
                        ])),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CoursePage(course: user.courses[index])));
                },
              )),
              color: Colors.transparent);
        });

    final grades = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent])),
      child: Column(children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 5.0),
            child: Text("Grades",
                style: TextStyle(fontSize: 32.0, color: Colors.white))),
        Expanded(child: gradesContent)
      ]),
    );

    return Scaffold(
      body: Swiper(
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return home;
            case 1:
              return grades;
          }
        },
        itemCount: 2,
        pagination: SwiperPagination(),
        control: SwiperControl(),
      ),
    );
  }
}
