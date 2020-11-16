// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/calendar_page.dart';
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
    currentIndex = 0;
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
      print("Index $currentIndex");
    });
  }

  Future<bool> _onBackPressed() {
    if (currentIndex == 0) {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit an App'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("NO"),
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                    onTap: () => Io.exit(0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text("YES"),
                    )),
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
              canvasColor: Color(0xff0066ff),
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.white,
              textTheme: Theme.of(context).textTheme.copyWith(
                    caption: new TextStyle(color: Colors.white30),
                  )), // sets the inactive color of the `BottomNavigationBar`
          child: new BottomNavigationBar(
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
                  'Calendar',
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

        //  bottomNavigationBar: BubbleBottomBar(
        //     backgroundColor: Color(0xff0066ff),
        //     hasNotch: true,
        //     opacity: 1,
        //     // backgroundColor:
        //     currentIndex: currentIndex,
        //     onTap: changePage,
        //     borderRadius: BorderRadius.vertical(
        //       top: Radius.circular(16),
        //     ), //border radius doesn't work when the notch is enabled.
        //     elevation: 8,
        //     items: <BubbleBottomBarItem>[
        //       BubbleBottomBarItem(
        //         backgroundColor: Colors.white,
        //         icon: Icon(
        //           Icons.home_outlined,
        //           color: Colors.white,
        //         ),
        //         activeIcon: Icon(
        //           Icons.home,
        //           color: Color(0xff0083fd),
        //         ),
        //         title: Text(
        //           "Home",
        //           style: GoogleFonts.montserrat(
        //             textStyle: TextStyle(
        //               fontWeight: FontWeight.w400,
        //               color: Color(0xff0083fd),
        //               fontSize: 13,
        //             ),
        //           ),
        //         ),
        //       ),
        //       BubbleBottomBarItem(
        //           backgroundColor: Colors.white,
        //           icon: Icon(
        //             Icons.calendar_today_outlined,
        //             color: Colors.white,
        //             size: 18,
        //           ),
        //           activeIcon: Icon(
        //             Icons.calendar_today_rounded,
        //             color: Color(0xff0083fd),
        //             size: 18,
        //           ),
        //           title: Text(
        //             "Attendance",
        //             style: GoogleFonts.montserrat(
        //               textStyle: TextStyle(
        //                 fontWeight: FontWeight.w400,
        //                 color: Color(0xff0083fd),
        //                 fontSize: 13,
        //               ),
        //             ),
        //           )),
        //       BubbleBottomBarItem(
        //           backgroundColor: Colors.white,
        //           icon: Icon(
        //             Icons.account_circle_outlined,
        //             color: Colors.white,
        //           ),
        //           activeIcon: Icon(
        //             Icons.account_circle_rounded,
        //             color: Color(0xff0083fd),
        //           ),
        //           title: Text(
        //             "Profile",
        //             style: GoogleFonts.montserrat(
        //               textStyle: TextStyle(
        //                 fontWeight: FontWeight.w400,
        //                 color: Color(0xff0083fd),
        //                 fontSize: 13,
        //               ),
        //             ),
        //           )),
        //       BubbleBottomBarItem(
        //           backgroundColor: Colors.white,
        //           icon: Icon(
        //             Icons.settings_outlined,
        //             color: Colors.white,
        //           ),
        //           activeIcon: Icon(
        //             Icons.settings_rounded,
        //             color: Color(0xff0083fd),
        //           ),
        //           title: Text(
        //             "Settings",
        //             style: GoogleFonts.montserrat(
        //               textStyle: TextStyle(
        //                 fontWeight: FontWeight.w400,
        //                 color: Color(0xff0083fd),
        //                 fontSize: 13,
        //               ),
        //             ),
        //           ))
        //     ],
        //   ),
      ),
    );
  }
}
