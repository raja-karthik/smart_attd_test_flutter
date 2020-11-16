import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          //elevation: 0,
          backgroundColor: Color(0xff0066ff),
          leading: Container(),
          title: new Text("SETTINGS",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w400,
              )))),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(40, 50, 40, 0),
            width: double.infinity,
            child: RaisedButton(
              child: new Text('Logout'),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: () {
                logOut();
              },
            ),
          ),
        ],
      ),
    );
  }

  logOut() {
    removeValues();
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: LoginPage(),
      ),
    );
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.clear();
    // prefs.remove("selectedDay");
    // prefs.remove("selectedMonth");
    // prefs.remove("loggedin");
    // prefs.remove("token");
  }
}
