import 'package:flutter/material.dart';
import 'package:grade_view/api.dart';
import 'dart:convert'; //json
import 'globals.dart' as globals;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'course_page.dart';

class HomePage extends StatefulWidget {
  static const String tag = 'home-page';

  @override
  _MainState createState() => new _MainState();
}
class _MainState extends State<HomePage> {

  void init() async {
    final courses = jsonDecode((await API.getGrades(globals.user.username, await globals.storage.read(key: 'password'))).body)['courses'];
    globals.user.courses = [];
    courses.forEach((f) => globals.user.courses.add(globals.Course.fromJson(f as Map)));//globals.user.courses.add(globals.Course.fromJson(f as Map))); //globals.user.courses.add(globals.Course.fromJson(jsonDecode(v)))
    //cache grades
    // print(globals.user.courses.toString());
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
    final img = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Image.memory(base64.decode(globals.user.photo), scale: 0.7),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        globals.user.username,
        style: TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final school = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        globals.user.school,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );

    final classes = ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: globals.user.courses.length,
      itemBuilder: (BuildContext context, int index) {
        final String courseName = globals.user.courses[index].name.split(" (")[0];
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Center(child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: courseName, style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: globals.user.courses[index].name.split(courseName)[1]),
              ],
              style: TextStyle(fontSize: 16.0, color: Colors.white)
            )
          ))
        );
      },
    );

    final home = Container(
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
      itemCount: globals.user.courses.length,
      itemBuilder: (BuildContext context, int index) {
        final String courseName = globals.user.courses[index].name.split(" (")[0];
        return InkWell(
          child: Card(child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Align>[
                Align(child: RichText(text: TextSpan(text: courseName, style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold))), alignment: Alignment.centerLeft),
                Align(child: RichText(text: TextSpan(text: globals.user.courses[index].name.split(courseName)[1], style: TextStyle(fontSize: 16.0, color: Colors.black))), alignment: Alignment.centerLeft),
                Align(child: RichText(text: TextSpan(text: globals.user.courses[index].letterGrade+" ("+globals.user.courses[index].percentage.toString()+")", style: TextStyle(fontSize: 16.0, color: Colors.black))), alignment: Alignment.centerRight)
              ]
            )
          )),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CoursePage(course: globals.user.courses[index]))
            );
          });
      }
    );

    final grades = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent
        ])
      ),
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 5.0), child: Text("Grades", style: TextStyle(fontSize: 32.0, color: Colors.white))),
          Expanded(child: gradesContent)
        ]
      ),
    );

    return Scaffold(
      body: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          switch(index) {
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
