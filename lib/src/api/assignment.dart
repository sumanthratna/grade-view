import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart' show required;

class Assignment {
  String name;
  String assignmentType;
  DateTime date;
  DateTime dueDate;
  Decimal achievedScore, maxScore;
  Decimal achievedPoints, maxPoints;
  String notes;
  bool real = true;

  Assignment(
      {@required final this.name,
      @required final this.assignmentType,
      @required final this.date,
      @required final this.dueDate,
      @required final this.achievedScore,
      @required final this.maxScore,
      @required final this.achievedPoints,
      @required final this.maxPoints,
      @required final this.notes,
      final this.real});

  Assignment.fromJson(final Map<String, dynamic> json)
      : name = json['name'],
        assignmentType = json['assignment_type'],
        notes = json['notes'],
        date = DateTime.parse(json['date']),
        dueDate = DateTime.parse(json['due_date']) {
    final score = json['score'].split(' out of ');
    achievedScore = Decimal.tryParse(score[0]);
    maxScore = Decimal.tryParse(score[score.length == 2 ? 1 : 0]);
    final points = json['points'].split(' / ');
    achievedPoints = Decimal.tryParse(points[0]);
    maxPoints = Decimal.tryParse(
        points.length == 2 ? points[1] : points[0].split(' ')[0]);
  }

  Map<String, String> toJson() => {
        'name': name,
        'assignment_type': assignmentType,
        'date': date.toString(),
        'due_date': dueDate.toString(),
        'achieved_score': achievedScore.toString(),
        'max_score': maxScore.toString(),
        'achieved_points': achievedPoints.toString(),
        'max_points': maxPoints.toString(),
        'notes': notes
      };

  String toString() => toJson().toString();
}
