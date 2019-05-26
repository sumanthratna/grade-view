import 'package:flutter/material.dart'
    show
        BuildContext,
        ListView,
        MaterialPageRoute,
        Navigator,
        NeverScrollableScrollPhysics,
        RouteSettings,
        State,
        StatefulWidget,
        Widget;
import 'package:grade_view/api.dart' show Assignment, Course;
import 'package:grade_view/widgets.dart' show BreakdownTableSource, InfoCard;
import 'package:provider/provider.dart' show Consumer, Provider;

import '../../assignment_page.dart' show AssignmentPage;

class AssignmentList extends StatefulWidget {
  final Course course;
  AssignmentList(final this.course);
  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {
  @override
  Widget build(final BuildContext context) {
    final BreakdownTableSource notifier =
        Provider.of<BreakdownTableSource>(context);
    final List<Assignment> assignmentsToShow = notifier
            .stateCurrentlySelected.isEmpty
        ? widget.course.assignments
        : widget.course.assignments
            .where((final Assignment element) => notifier.stateCurrentlySelected
                .contains(element.assignmentType))
            .toList();
    return Consumer<BreakdownTableSource>(
        builder: (final BuildContext context,
                final BreakdownTableSource breakdownTableSource, _) =>
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignmentsToShow.length,
                shrinkWrap: true,
                itemBuilder: (final BuildContext context, final int index) => InfoCard(
                    left: assignmentsToShow[index].name,
                    right: ' ' +
                        assignmentsToShow[index].achievedPoints.toString() +
                        '/' +
                        assignmentsToShow[index].maxPoints.toString(),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings:
                                const RouteSettings(name: 'assignment-page'),
                            builder: (final BuildContext context) =>
                                AssignmentPage(
                                    course: widget.course,
                                    assignment: assignmentsToShow[index]))))));
  }
}
