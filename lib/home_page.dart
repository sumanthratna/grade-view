import 'dart:convert' show jsonDecode;
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging, IosNotificationSettings;
import 'package:flutter/material.dart'
    show
        AppBar,
        Border,
        BoxDecoration,
        BuildContext,
        Center,
        Colors,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        FontWeight,
        GlobalKey,
        Hero,
        Icon,
        Icons,
        IconThemeData,
        Key,
        ListView,
        MaterialPageRoute,
        MediaQuery,
        ModalRoute,
        mustCallSuper,
        Navigator,
        Padding,
        protected,
        RichText,
        RouteSettings,
        Scaffold,
        ScaffoldState,
        SingleTickerProviderStateMixin,
        State,
        StatelessWidget,
        StatefulWidget,
        SwitchListTile,
        Tab,
        TabBar,
        TabBarView,
        TabController,
        Text,
        TextSpan,
        TextStyle,
        Widget;
import 'package:grade_view/widgets.dart'
    show BackBar, InfoCard, LoadingIndicator;

import 'package:grade_view/api.dart' show API, Course;
import 'package:grade_view/course_page.dart' show CoursePage;
import 'package:grade_view/globals.dart' show decoration, storage, user;

class GradesTab extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    final Widget grades = ListView.builder(
        itemCount: user.courses.length,
        itemBuilder: (final BuildContext context, final int index) => InfoCard(
            key: Key(user.courses[index].id),
            left: user.courses[index].name,
            right: '${user.courses[index].letterGrade} '
                '\(${user.courses[index].percentage.toStringAsFixed(user.courses[index].courseMantissaLength)}\%\)',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(name: 'course-page'),
                    builder: (final BuildContext context) =>
                        CoursePage(course: user.courses[index])))));

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
      child: Column(children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text('Grades',
                style: TextStyle(fontSize: 32.0, color: Colors.white))),
        Expanded(child: grades)
      ]),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class SettingsTab extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging;
  final bool _firebaseDeviceStatus;
  SettingsTab(final this._firebaseMessaging, final this._firebaseDeviceStatus);

  @override
  Widget build(final BuildContext context) {
    final Widget settings = Column(children: <Widget>[
      // test adaptive constructor
      SwitchListTile.adaptive(
          title: const Text('Enable push notifications',
              style: TextStyle(color: Colors.white)),
          value: _firebaseDeviceStatus,
          onChanged: (final bool newValue) async =>
              await API.setActivationForDevice(
                  _firebaseMessaging,
                  user.username,
                  await storage.read(key: 'gradeviewpassword'),
                  newValue))
    ]);

    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: decoration,
        child: Column(children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text('Settings',
                  style: TextStyle(fontSize: 32.0, color: Colors.white))),
          settings
        ]));
  }
}

class UserTab extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
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
        itemBuilder: (final BuildContext context, final int index) => Container(
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
                  const TextSpan(text: ' '),
                  TextSpan(
                      text: user.courses[index].id,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                ])))));

    return Container(
      key: const Key('base'),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(28.0),
      decoration: decoration,
      child: Column(
        children: <Widget>[img, welcome, school, Expanded(child: classes)],
      ),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _firebaseDeviceActive = false;

  final List<Widget> _tabs = List<Widget>(3);
  TabController _tabController;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(final BuildContext context) {
    if (user.courses == null || user.courses.isEmpty) {
      return const LoadingIndicator();
    }

    _tabs[0] = UserTab();
    _tabs[1] = GradesTab();
    _tabs[2] = SettingsTab(_firebaseMessaging, _firebaseDeviceActive);

    return Scaffold(
      key: _scaffoldKey,
      appBar: BackBar(
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
            Tab(icon: Icon(Icons.person), text: 'User'),
            Tab(icon: Icon(Icons.school), text: 'Grades'),
            /*Tab(icon: Icon(Icons.show_chart), text: 'Charts')*/
            Tab(icon: Icon(Icons.settings), text: 'Settings')
          ]),
    );
  }

  void clearPassword() async => await storage.delete(key: 'gradeviewpassword');

  @protected
  @mustCallSuper
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchActive() async =>
      _firebaseDeviceActive = await API.getActivationForDevice(
          _firebaseMessaging,
          user.username,
          await storage.read(key: 'gradeviewpassword'));

  void fetchUser() async {
    final List<dynamic> fetchedGrades = jsonDecode((await API.getGrades(
            user.username, await storage.read(key: 'gradeviewpassword')))
        .body)['courses'];
    fetchedGrades.forEach((final dynamic f) =>
        user.courses.add(Course.fromJson(f as Map<String, dynamic>)));
    refreshUserCoursesList();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) {
      iosPermission();
    }

    _firebaseMessaging
        .getToken()
        .then((final String token) => print('Firebase token: $token'));

    _firebaseMessaging.configure(
      onMessage: (final Map<String, dynamic> message) async =>
          print('Firebase on message $message'),
      onResume: (final Map<String, dynamic> message) async =>
          print('Firebase on resume $message'),
      onLaunch: (final Map<String, dynamic> message) async =>
          print('Firebase on launch $message'),
    );
  }

  @protected
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchActive();
    setupTabController();
    firebaseCloudMessagingListeners();
    clearPassword();
  }

  void iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen(
        (final IosNotificationSettings settings) =>
            print("Firebase settings registered: $settings"));
    _firebaseMessaging.setAutoInitEnabled(true);
  }

  void refreshUserCoursesList() =>
      setState(() => user.courses = List<Course>.from(user.courses));

  void setupTabController() =>
      _tabController = TabController(vsync: this, length: 3);
}
