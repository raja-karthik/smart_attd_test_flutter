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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/content_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
            child: Column(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'GENERAL INFO',
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            color: Color(0xff0066ff),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Staff ID',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'SA - 007',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Staff Type',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'Administration',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'PERSONAL INFO',
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            color: Color(0xff0066ff),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'First Name',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'XXXXXX',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Last Name',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'Y',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Gender',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'Male',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Mobile Number',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              '8807882578',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Email',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'xyz@gmail.com',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 180,
                              child: Text(
                                'Address',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                  color: Color(0xff0083fd),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                            ),
                            Text(
                              'Chennai',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
