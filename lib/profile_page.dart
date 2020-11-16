import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          //elevation: 0,
          backgroundColor: Color(0xff0066ff),
          leading: Container(),
          title: new Text("PROFILE",
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w400,
              )))),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
