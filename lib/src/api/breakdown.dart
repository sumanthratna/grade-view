import 'dart:collection' show ListBase;

import 'package:decimal/decimal.dart' show Decimal;
import 'package:grade_view/api.dart' show Weighting;

class Breakdown extends ListBase<Weighting> {
  List<Weighting> weightings;

  Breakdown() : weightings = <Weighting>[];
  Breakdown.fromList(final this.weightings);

  int get length => weightings.length;
  set length(final int length) => weightings.length = length;
  Weighting operator [](final dynamic arg) {
    if (arg is int) {
      // The argument is an index.
      return weightings[arg];
    } else if (arg is String) {
      // The argument is the name of the desired [Weighting].
      // Creates map-like behavior.
      return weightings[
          weightings.map((final Weighting f) => f.name).toList().indexOf(arg)];
    } else {
      return null;
    }
  }

  void operator []=(final dynamic arg, final Weighting value) {
    if (arg is int) {
      weightings[arg] = value;
    } else if (arg is String) {
      final List<String> weightingNames =
          weightings.map((final Weighting f) => f.name);
      if (weightings.map((final Weighting f) => f.name).contains(arg)) {
        weightings[weightingNames.toList().indexOf(arg)] = value;
      } else {
        weightings.add(value);
      }
    }
  }

  void add(final Weighting value) => weightings.add(value);
  void addAll(final Iterable<Weighting> all) => weightings.addAll(all);

  Map<String, Decimal> toJson() {
    Map<String, Decimal> out = Map<String, Decimal>();
    for (final Weighting weighting in weightings) {
      out[weighting.name] = weighting.percentage;
    }
    return out;
  }

  String toString() => toJson().toString();
}
