import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class CoursePage extends StatelessWidget {
  static const String tag = 'course-page';

  globals.Course course;

  CoursePage({Key key, @required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courseInfo = Card(
      child: Text("hi")
    );

    final courseGrades = ListView.builder(
      itemCount: this.course.assignments.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Card(child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Align>[
                Align(child: Text(course.assignments[index].name, style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.fade), alignment: Alignment.centerLeft),
                Align(child: Text(course.assignments[index].achievedPoints.toString()+"/"+course.assignments[index].maxPoints.toString(), style: TextStyle(fontSize: 16.0, color: Colors.black)), alignment: Alignment.centerRight)
              ],
            )
          ))
        );
      }
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),
      child: Column(
        children: <Widget>[courseInfo, Expanded(child: courseGrades)]
      ),
    );

    return Scaffold(
      body: body
    );
  }
}
