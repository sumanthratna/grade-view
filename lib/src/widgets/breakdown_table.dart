import 'package:flutter/material.dart'
    show
        BuildContext,
        DataCell,
        DataColumn,
        DataRow,
        DataTable,
        DataTableSource,
        State,
        StatefulWidget,
        Text,
        Widget;

import 'package:grade_view/api.dart' show Breakdown, Weighting;

class BreakdownTable extends StatefulWidget {
  /// To access `currentlySelected` from [CoursePage].
  final _BreakdownTableState state = _BreakdownTableState();
  final Breakdown breakdown;

  BreakdownTable(final this.breakdown);

  @override
  State<BreakdownTable> createState() => state;
}

class BreakdownTableSource extends DataTableSource {
  List<Weighting> weightings;
  List<String> currentlySelected;
  List<DataRow> rows;

  BreakdownTableSource()
      : weightings = List<Weighting>(),
        currentlySelected = List<String>(),
        rows = List<DataRow>();
  BreakdownTableSource.fromWeightings(final this.weightings)
      : currentlySelected = List<String>() {
    setupRows();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => weightings.length;

  @override
  int get selectedRowCount => currentlySelected.length;

  List<DataColumn> getColumns() => const <DataColumn>[
        DataColumn(label: Text('Assignment\nType')),
        DataColumn(label: Text('Average')),
        DataColumn(label: Text('Weight')),
        DataColumn(label: Text('Points')),
        DataColumn(label: Text('Letter\nGrade'))
      ];

  DataRow getRow(final int index) => rows[index];

  List<DataRow> getRows() {
    List<DataRow> out = List<DataRow>(weightings.length);
    weightings.asMap().forEach(
        (final int key, final Weighting value) => out[key] = getRow(key));
    return out;
  }

  @override
  void notifyListeners() => super.notifyListeners();

  void setupRows() {
    rows.clear();
    weightings.asMap().forEach((final int index, final Weighting element) {
      rows.add(DataRow.byIndex(
        index: index,
        cells: <DataCell>[
          DataCell(Text('${element.name}')),
          DataCell(Text('${element.percentage.toInt()}%')),
          DataCell(Text('${element.weight}%')),
          DataCell(Text('${element.achievedPoints}/${element.maxPoints}')),
          DataCell(Text('${element.letterGrade}')),
        ],
        selected: currentlySelected.contains(element.name),
        onSelectChanged: element.name == "TOTAL"
            ? null
            : (final bool value) {
                if (value) {
                  currentlySelected.add(element.name);
                } else {
                  currentlySelected.remove(element.name);
                }
                notifyListeners();
              },
      ));
    });
    print('cw ' + currentlySelected.toString());
  }

  void setWeightings(final List<Weighting> weightings) {
    this.weightings = weightings;
    setupRows();
  }
}

class _BreakdownTableState extends State<BreakdownTable> {
  BreakdownTableSource breakdownTableSource = BreakdownTableSource();

  _BreakdownTableState() {
    breakdownTableSource.addListener(() {
      setState(() {
        breakdownTableSource.setupRows();
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    breakdownTableSource.setWeightings(widget.breakdown.weightings);
    return DataTable(
      rows: breakdownTableSource.getRows(),
      columns: breakdownTableSource.getColumns(),
      onSelectAll: (final bool value) {
        breakdownTableSource.currentlySelected.clear();
        if (value) {
          setState(() => breakdownTableSource.currentlySelected.addAll(widget
              .breakdown.weightings
              .map((final Weighting element) => element.name)
              .toList()
                ..remove("TOTAL")));
        } else {
          setState(() {});
        }
        breakdownTableSource.notifyListeners();
      },
    );
  }
}
