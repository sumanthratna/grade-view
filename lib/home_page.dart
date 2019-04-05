import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        SingleTickerProviderStateMixin,
        GlobalKey,
        ScaffoldState,
        Widget,
        TabController,
        protected,
        BuildContext,
        Hero,
        Padding,
        EdgeInsets,
        Container,
        BoxDecoration,
        Border,
        Colors,
        Text,
        TextStyle,
        ListView,
        Center,
        RichText,
        TextSpan,
        FontWeight,
        Key,
        MediaQuery,
        Column,
        Expanded,
        Navigator,
        MaterialPageRoute,
        RouteSettings,
        SwitchListTile,
        Scaffold,
        AppBar,
        IconThemeData,
        ModalRoute,
        TabBarView,
        TabBar,
        Tab,
        Icon,
        Icons,
        mustCallSuper,
        SnackBar,
        WidgetsBinding;

import 'api.dart' show API, Course;
import 'course_page.dart' show CoursePage;
import 'custom_widgets.dart' show LogoutBar, LoadingIndicator, Info;
import 'globals.dart' show user, storage, decoration;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _firebaseDeviceActive = false;

  bool _successDuringGradesFetch = false;

  final List<Widget> _tabs = <Widget>[];
  TabController _tabController;

  @override
  Widget build(final BuildContext context) {
    if (user.courses == null || user.courses.isEmpty) {
      return const LoadingIndicator();
    }

    final Widget img = Hero(
        tag: 'img',
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                child: user.photo,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 8.0)))));

    final Widget welcome = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        user.username,
        style: const TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final Widget school = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        user.school,
        style: const TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );

    final Widget classes = ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: user.courses.length,
      itemBuilder: (final BuildContext context, final int index) {
        return Container(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white),
                        children: <TextSpan>[
                  TextSpan(
                      text: user.courses[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: " "),
                  TextSpan(
                      text: user.courses[index].id,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                ]))));
      },
    );

    final Widget userScreen = Container(
      key: const Key('base'),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
      child: Column(
        children: <Widget>[img, welcome, school, Expanded(child: classes)],
      ),
    );

    final Widget grades = ListView.builder(
        itemCount: user.courses.length,
        itemBuilder: (final BuildContext context, final int index) {
          return Info(
              left: user.courses[index].name,
              right: _successDuringGradesFetch
                  ? (user.courses[index].letterGrade +
                      " (" +
                      user.courses[index].percentage.toString() +
                      ")")
                  : user.courses[index].teacher,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: 'course-page'),
                      builder: (final BuildContext context) =>
                          CoursePage(course: user.courses[index]))));
        });

    final Widget gradesScreen = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
      child: Column(children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text("Grades",
                style: TextStyle(fontSize: 32.0, color: Colors.white))),
        Expanded(child: grades)
      ]),
    );

    final Widget settings = SwitchListTile(
        title: const Text("Enable push notifications",
            style: TextStyle(color: Colors.white)),
        value: _firebaseDeviceActive,
        onChanged: (final bool newValue) async => newValue
            ? await API.registerDevice(
                user.username, await storage.read(key: 'gradeviewpassword'))
            : await API.setActivationForDevice(user.username,
                await storage.read(key: 'gradeviewpassword'), false));

    final Widget settingsScreen = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text("Settings",
                  style: TextStyle(fontSize: 32.0, color: Colors.white))),
          settings
        ]));

    _tabs.add(userScreen);
    _tabs.add(gradesScreen);
    _tabs.add(settingsScreen);

    return Scaffold(
      key: _scaffoldKey,
      appBar: LogoutBar(
          appBar: AppBar(
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: false),
          onTap: () => Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName))),
      body: TabBarView(children: _tabs, controller: _tabController),
      bottomNavigationBar: TabBar(
          controller: _tabController,
          indicatorWeight: 3.0,
          tabs: const <Tab>[
            Tab(icon: Icon(Icons.person), text: 'Home'),
            Tab(icon: Icon(Icons.school), text: 'Grades'),
            /*Tab(icon: Icon(Icons.show_chart), text: 'Charts')*/
            Tab(icon: Icon(Icons.settings), text: 'Settings')
          ]),
    );
  }

  @protected
  @mustCallSuper
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchActive() async =>
      _firebaseDeviceActive = await API.getActivationForDevice(
          user.username, await storage.read(key: 'gradeviewpassword'));

  void fetchUser() async {
    final unparsedGrades = jsonDecode((await API.getGrades(
            user.username, await storage.read(key: 'gradeviewpassword')))
        .body)['courses'];
    if (unparsedGrades == null) {
      _successDuringGradesFetch = false;
    } else {
      _successDuringGradesFetch = true;
      user.courses = [];
      unparsedGrades.forEach((final f) =>
          user.courses.add(Course.fromJson(f as Map<String, dynamic>)));
      setState(() => user.courses = List<Course>.from(user.courses));
      await storage.delete(key: 'gradeviewpassword');
    }
  }

  @protected
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchActive();
    WidgetsBinding.instance.addPostFrameCallback(
        (final Duration timestamp) => showUnableToFetchGradesSnackBar);
    setupTabController();
  }

  void refreshUserCoursesList() =>
      setState(() => user.courses = List<Course>.from(user.courses));

  void setupTabController() =>
      _tabController = TabController(vsync: this, length: 3);

  void showUnableToFetchGradesSnackBar() {
    print(_successDuringGradesFetch);
    if (!_successDuringGradesFetch) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          const SnackBar(content: Text('Unable to Fetch Grades')));
    }
  }
}
