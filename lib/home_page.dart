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

        // appBar: AppBar(
        //   title: Text(widget.title),
        //   actions: <Widget>[
        //     IconButton(icon: Icon(Icons.notifications), onPressed: () {})
        //   ],
        // ),
        // body: Stack(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         image: DecorationImage(
        //           image: AssetImage("assets/images/dashboard_bg.png"),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),
        //     Column(
        //       children: [
        //         Container(
        //           padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Row(
        //                 children: [
        //                   Container(
        //                     height: 80,
        //                     width: 80,
        //                     decoration: BoxDecoration(
        //                         border: Border.all(color: Colors.white),
        //                         borderRadius: BorderRadius.circular(40)),
        //                     child: CircleAvatar(
        //                       backgroundImage:
        //                           AssetImage('assets/images/no_image.png'),
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     width: 10,
        //                   ),
        //                   Text(
        //                     "Name",
        //                     style: GoogleFonts.montserrat(
        //                       color: Colors.white,
        //                       fontSize: 18,
        //                       fontWeight: FontWeight.w500,
        //                       letterSpacing: 1,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //               Icon(
        //                 Icons.notifications,
        //                 color: Colors.white,
        //                 size: 30.0,
        //               )
        //             ],
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.symmetric(vertical: 20.0),
        //           height: 50.0,
        //           child: ListView(
        //             scrollDirection: Axis.horizontal,
        //             children: <Widget>[
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.red,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.blue,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.green,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.yellow,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.orange,
        //               ),
        //               Container(
        //                 width: 60.0,
        //                 color: Colors.red,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.blue,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.green,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.yellow,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.orange,
        //               ),
        //               Container(
        //                 width: 60.0,
        //                 color: Colors.red,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.blue,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.green,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.yellow,
        //               ),
        //               Container(
        //                 width: 100.0,
        //                 color: Colors.orange,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),

        bottomNavigationBar: BubbleBottomBar(
          backgroundColor: Color(0xff0066ff),
          hasNotch: true,
          opacity: 1,
          // backgroundColor:
          currentIndex: currentIndex,
          onTap: changePage,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ), //border radius doesn't work when the notch is enabled.
          elevation: 8,
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              backgroundColor: Colors.white,
              icon: Icon(
                Icons.home_outlined,
                color: Colors.white,
              ),
              activeIcon: Icon(
                Icons.home,
                color: Color(0xff0083fd),
              ),
              title: Text(
                "Home",
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xff0083fd),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                activeIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xff0083fd),
                  size: 18,
                ),
                title: Text(
                  "Attendance",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0083fd),
                      fontSize: 13,
                    ),
                  ),
                )),
            BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
                activeIcon: Icon(
                  Icons.account_circle_rounded,
                  color: Color(0xff0083fd),
                ),
                title: Text(
                  "Profile",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0083fd),
                      fontSize: 13,
                    ),
                  ),
                )),
            BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
                activeIcon: Icon(
                  Icons.settings_rounded,
                  color: Color(0xff0083fd),
                ),
                title: Text(
                  "Settings",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0083fd),
                      fontSize: 13,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
