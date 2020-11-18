import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/home_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_flutterapp/main.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var profileData;
  var profileUrl;
  bool _showLoading = true;

  @override
  void initState() {
    loadProfileData();
    super.initState();
  }

  loadProfileData() async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/profile';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    profileUrl = prefs.getString('profile_url');
    // var datenow = new DateTime.now();

    var input = {'token': token};
    String jsnstr = jsonEncode(input);
    print('API INPUT $jsnstr');

    var response = await http.post(url, body: input);

    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');
    if (response.statusCode == 200) {
      setState(() {
        if (res['status'] == 'success') {
          // if (res['data'] != null) {
          _showLoading = false;
          profileData = res['profile'];
          // }
        } else {
          if (res['token_invalid'] == 'true') {
            CoolAlert.show(
              context: context,
              barrierDismissible: false,
              confirmBtnText: 'OK',
              confirmBtnColor: Color(0xff0083fd),
              onConfirmBtnTap: () {
                logOut();
              },
              type: CoolAlertType.warning,
              title: "Token Expired",
              text:
                  "Looks like you logged into another device, Please login here to continue using in this device",
            );
          } else {
            return showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => new AlertDialog(
                    title: new Text('Alert'),
                    content: new Text('${res['message']}'),
                    actions: <Widget>[
                      new GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).pop(false);
                            // _showLoading = false;
                            // print(_showLoading);
                          });

                          // Navigator.push(
                          //   context,
                          //   PageTransition(
                          //     type: PageTransitionType.fade,
                          //     child: MyHomePage(title: 'Home'),
                          //   ),
                          // );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "OK",
                            style: TextStyle(color: Color(0xff0083fd)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ) ??
                false;
          }
        }
      });
    } else {
      print('RES CODE = ${res['status']}');
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: MyHomePage(title: 'Home'),
        ),
      );
    }
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
  }

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
          _showLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                child: profileUrl != null
                                    ? Image.network(
                                        "$profileUrl",
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/images/no_image.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Container(
                                // padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Container(
                                        // margin: EdgeInsets.only(left: 20),
                                        height: 35,
                                        width: 35,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(35.0),
                                          child: Image.network(
                                            "$profileUrl",
                                          ),
                                        ),
                                      ),
                                      title: new Text(
                                        '${profileData['first_name']} ${profileData['last_name']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Name'),
                                    ),
                                    ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.phone,
                                          ),
                                        ],
                                      ),
                                      title: new Text(
                                        '${profileData['mobile']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Mobile'),
                                    ),
                                    ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.mail_rounded,
                                          ),
                                        ],
                                      ),
                                      title: new Text(
                                        '${profileData['email']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Email'),
                                    ),
                                    ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                          ),
                                        ],
                                      ),
                                      title: new Text(
                                        '${profileData['address']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Address'),
                                    ),
                                    ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.payment_rounded,
                                          ),
                                        ],
                                      ),
                                      title: new Text(
                                        '${profileData['id']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Staff ID'),
                                    ),
                                    ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.people_rounded,
                                          ),
                                        ],
                                      ),
                                      title: new Text(
                                        '${profileData['type']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text('Staff Type'),
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
                )
        ],
      ),
    );
  }
}
