import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class CoursePage extends StatelessWidget {
  static const String tag = 'course-page';

  final globals.Course course;

  CoursePage({Key key, @required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backButton = Padding(
      child: Align(child: BackButton(), alignment: Alignment.centerLeft),
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0));

    final courseInfo = Card(
      child: DataTable(
        rows: this.course.breakdown.getDataRows(),
        columns: this.course.breakdown.getDataColumns()),
      margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 15.0));

    final courseGrades = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: this.course.assignments.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(this.course.assignments[index].name,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                      overflow: TextOverflow.fade,
                      maxLines: 1
                    )
                  ),
                  Align(
                    child: Text(
                      this.course.assignments[index].achievedPoints
                          .toString() +
                        "/" +
                        this.course.assignments[index].maxPoints
                          .toString(),
                      style: TextStyle(
                        fontSize: 16.0, color: Colors.black)),
                    alignment: Alignment.centerRight)
                ]
              )
            )
          )
        );
      });

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
        Colors.blue,
        Colors.lightBlueAccent,
        ]),
      ),
      child: Column(children: <Widget>[
        backButton,
        Text(this.course.name,
          style: TextStyle(fontSize: 32.0, color: Colors.white)),
        Expanded(
          child: ListView(children: <Widget>[courseInfo, courseGrades]))
      ]));

    return Scaffold(body: body);
  }
}
