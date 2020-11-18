import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './dashboard_page.dart';
import './calendar_page.dart';
import './profile_page.dart';
import './settings_page.dart';
import 'dart:io' as Io;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex;
  @override
  void initState() {
    super.initState();
    _getPermission();
    _getCurrentIndex();
  }

  _getCurrentIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('bottomBarIndex');

    setState(() {
      if (index != null) {
        currentIndex = index;
        prefs.setInt('bottomBarIndex', 0);
      } else {
        currentIndex = 0;
      }
    });
  }

  _getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print('Location Permission =>  $permission');
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    print("Index $currentIndex");
  }

  Future<bool> _onBackPressed() {
    if (currentIndex == 0) {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Confirm'),
              content: new Text('Are you sure you want to exit ?'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Io.exit(0),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("YES"),
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "NO",
                      style: TextStyle(color: Color(0xff0083fd)),
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: currentIndex == 0
            ? DashboardHomePage()
            : (currentIndex == 1
                ? CalendarPage()
                : (currentIndex == 2
                    ? ProfilePage()
                    : (currentIndex == 3 ? SettingsPage() : null))),
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(

              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.white,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Color(0xff0066ff),
              textTheme: Theme.of(context).textTheme.copyWith(
                    caption: new TextStyle(color: Colors.grey),
                  )), // sets the inactive color of the `BottomNavigationBar`

          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                ),
              ],
            ),
            child: new BottomNavigationBar(
              elevation: 10,
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: changePage,
              items: [
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.home_outlined),
                  // label: 'Home',
                  title: new Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  activeIcon: new Icon(Icons.home),
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.calendar_today_outlined),
                  // label: 'Calendar',
                  title: new Text(
                    'Attendance',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  //label: 'Profile',
                  title: new Text(
                    'Profile',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  activeIcon: Icon(Icons.account_circle_rounded),
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  // label: 'Settings',
                  title: new Text(
                    'Settings',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  activeIcon: Icon(Icons.settings_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
