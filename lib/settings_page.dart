import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
