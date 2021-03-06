import 'package:flutter/material.dart'
    show
        BuildContext,
        DataCell,
        DataColumn,
        DataRow,
        DataTable,
        DataTableSource,
        MediaQuery,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:grade_view/api.dart' show Weighting;

class BreakdownTable extends StatefulWidget {
  final List<DataRow> rows;
  final List<DataColumn> columns;
  BreakdownTable(final this.rows, final this.columns);

  @override
  State<BreakdownTable> createState() => _BreakdownTableState();
}

class BreakdownTableSource extends DataTableSource {
  List<Weighting> weightings;
  List<String> _currentlySelected;
  List<DataRow> rows;

  BreakdownTableSource()
      : weightings = List<Weighting>(),
        _currentlySelected = List<String>(),
        rows = List<DataRow>();
  BreakdownTableSource.fromWeightings(final this.weightings)
      : _currentlySelected = weightings
            .map((final Weighting e) => e.name)
            .toList()
              ..remove((final String value) => value == 'TOTAL'),
        rows = <DataRow>[] {
    setupRows();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => weightings.length;

  @override
  int get selectedRowCount => _currentlySelected.length;

  List<String> get stateCurrentlySelected => _currentlySelected;

  set stateCurrentlySelected(final List<String> newCurrentlySelected) {
    _currentlySelected = newCurrentlySelected;
    notifyListeners();
  }

  List<DataColumn> getColumns() => const <DataColumn>[
        DataColumn(label: Text('Assignment Type')),
        DataColumn(label: Text('Average')),
        DataColumn(label: Text('Weight')),
        DataColumn(label: Text('Points')),
        DataColumn(label: Text('Letter Grade'))
      ];

  DataRow getRow(final int index) => rows[index];

  List<DataRow> getRows() {
    List<DataRow> out = List<DataRow>(weightings.length);
    weightings.asMap().forEach(
        (final int key, final Weighting value) => out[key] = getRow(key));
    return out;
  }

  void setupRows() {
    rows.clear();
    weightings.asMap().forEach((final int index, final Weighting element) =>
        rows.add(DataRow.byIndex(
          index: index,
          cells: <DataCell>[
            DataCell(Text('${element.name}')),
            DataCell(Text('${element.percentage.toInt()}%')),
            DataCell(Text('${element.weight}%')),
            DataCell(Text('${element.achievedPoints}/${element.maxPoints}')),
            DataCell(Text('${element.letterGrade}')),
          ],
          selected: _currentlySelected.contains(element.name),
          onSelectChanged: element.name == "TOTAL"
              ? null
              : (final bool value) {
                  if (value && !_currentlySelected.contains(element.name)) {
                    _currentlySelected.add(element.name);
                  } else {
                    _currentlySelected.remove(element.name);
                  }
                  setupRows();
                  notifyListeners();
                },
        )));
  }

  void setWeightings(
      final BuildContext context, final List<Weighting> weightings) {
    this.weightings = weightings;
    setupRows();
  }
}

class _BreakdownTableState extends State<BreakdownTable> {
  List<String> _currentlySelected = <String>[];

  @override
  Widget build(final BuildContext context) => SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DataTable(
          rows: widget.rows, columns: widget.columns, onSelectAll: null));
}
