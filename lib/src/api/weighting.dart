import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart' show required;
import 'package:grade_view/api.dart' show getMantissaLength;

class Weighting {
  final String name;
  final Decimal weight;
  String letterGrade;
  Decimal percentage;
  Decimal achievedPoints, maxPoints;
  final int weightingMantissaLength;

  Weighting(
      {@required final this.name,
      @required final String weight,
      @required final this.letterGrade,
      @required final String percentage,
      @required final String achievedPoints,
      @required final String maxPoints})
      : weight = Decimal.parse(weight),
        percentage = Decimal.parse(percentage),
        achievedPoints = Decimal.parse(achievedPoints),
        maxPoints = Decimal.parse(maxPoints),
        weightingMantissaLength = getMantissaLength(percentage);

  Weighting.fromJson(final String name, final Map<String, dynamic> json)
      : name = name,
        weight = Decimal.parse(json['weight']),
        letterGrade = json['letter_grade'],
        percentage = Decimal.parse(json['percentage']),
        achievedPoints = Decimal.parse(json['points'].replaceAll(',', '')),
        maxPoints = Decimal.parse(json['points_possible'].replaceAll(',', '')),
        weightingMantissaLength = getMantissaLength(json['percentage']);

  Map<String, String> toJson() => {
        'name': name,
        'weight': weight.toString(),
        'letter_grade': letterGrade,
        'percentage': percentage.toString(),
        'achieved_points': achievedPoints.toString(),
        'max_points': maxPoints.toString()
      };

  String toString() => toJson().toString();
}
