import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './camera_page.dart';
import './main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  // final Position currLocation;
  // MapPage({Key key, @required this.currLocation}) : super(key: key);
  final List selectedDateArr;
  MapPage({Key key, this.selectedDateArr}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = [];
  String latitudeData = '';
  String longitudeData = '';

  String _locality = '';
  double lati = 0;
  double longi = 0;
  String _punchinTime = '';
  String _punchoutTime = '';
  bool _pinchinEnabled = false;
  bool _pinchoutEnabled = false;
  String formattedDate;
  var datenow = new DateTime.now();
  CameraPosition initialPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );
  Position _currentPosition;
  String _currentAddress;
  var selectedMonth;
  var selectedDate;
  var selectedDay;
  bool _showLoading = true;
  @override
  void initState() {
    super.initState();

    _pinchinEnabled = false; // Enable punch in button
    _pinchoutEnabled = false;
    _getCurrentLocation();
    _loadAttendanceData();
  }

  _loadAttendanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedMonth = prefs.getString('selectedMonth');
    selectedDate = prefs.getString('selectedDate');
    selectedDay = prefs.getString('selectedDay');
    var formatter = new DateFormat('MMM');
    var formatterdate = new DateFormat('dd');
    String currMonth = formatter.format(datenow);
    String currDate = formatterdate.format(datenow);
    if (selectedMonth == currMonth && selectedDate == currDate) {
      // _getCurrentLocation();
      _userSignInOutStatus();
    } else {
      _showLoading = false;
    }

    var sDArray = widget.selectedDateArr;

    setState(() {
      if (sDArray != null) {
        _punchinTime = widget.selectedDateArr[0]['in'];
        _punchoutTime =
            widget.selectedDateArr[widget.selectedDateArr.length - 1]['out'];
      } else {
        _punchinTime = '-';
        _punchoutTime = '-';
      }
    });
  }

  _userSignInOutStatus() async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/sign_type';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var input = {'token': token};
    String jsnstr = jsonEncode(input);
    print('API INPUT $jsnstr');

    var response = await http.post(url, body: input);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');

    if (response.statusCode == 200) {
      setState(() {
        _showLoading = false;
      });

      if (res['status'] == 'success') {
        setState(() {
          if (res['action'] == 'in') {
            _pinchinEnabled = !res['disable'];
          } else if (res['action'] == 'out') {
            _pinchoutEnabled = !res['disable'];
          }
        });
      } else {
        if (res['token_invalid']) {
          return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => new AlertDialog(
                  title: new Text('Token Expired'),
                  content: new Text(
                      'Looks like you logged into another device, Please login here to continue using in this device'),
                  actions: <Widget>[
                    new GestureDetector(
                      onTap: () {
                        logOut();
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
    } else {
      setState(() {
        _showLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Service Unreachable'),
        duration: Duration(milliseconds: 2000),
      ));
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

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      var formatter = new DateFormat('MMM');
      var formatterdate = new DateFormat('dd');
      String currMonth = formatter.format(datenow);
      String currDate = formatterdate.format(datenow);
      setState(() {
        _currentPosition = position;

        if (selectedMonth == currMonth && selectedDate == currDate) {
          latitudeData = '${position.latitude}';
          longitudeData = '${position.longitude}';
        } else {
          latitudeData = '0';
          longitudeData = '0';
        }

        lati = double.parse(latitudeData);
        longi = double.parse(longitudeData);
        initialPosition = CameraPosition(
          target: LatLng(lati, longi),
          zoom: 16,
        );
        _markers.add(Marker(
          markerId: MarkerId('myMarker'),
          draggable: false,
          onTap: () {
            print("Marker tapped");
          },
          position: LatLng(lati, longi),
        ));
      });

      _goToCurrent();

      if (selectedMonth == currMonth && selectedDate == currDate) {
        _getAddressFromLatLng();
      } else {
        setState(() {
          _currentAddress = "-";
          _locality = '-';
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.subLocality}, ${place.locality}, ${place.country}";
        if (place.subLocality != place.locality) {
          _locality = '${place.subLocality}, ${place.locality}';
        } else {
          _locality = '${place.locality}';
        }
      });
      print('CURRENT ADDRESS ======> $_currentAddress');
    } catch (e) {
      print(e);
    }
  }

  openCameraPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentLatitude', latitudeData);
    prefs.setString('currentLongitude', longitudeData);
    availableCameras().then((cameras) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: CameraPage(cameras),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(title: Text('Map Page')),
      body: _showLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Container(
                  height: size.height - 300,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    scrollGesturesEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: initialPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      setState(() {
                        _markers.add(Marker(
                          markerId: MarkerId('1'),
                          position: LatLng(lati, longi),
                          icon: BitmapDescriptor.defaultMarker,
                        ));
                      });
                    },
                    markers: Set.from(_markers),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 50,
                    left: 20,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.keyboard_backspace),
                    color: Color(0xff0083fd),
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
                Container(
                    height: 350,
                    margin: EdgeInsets.only(
                      top: size.height - 350,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/dashboard_bg.jpg"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffa3b1c6), // darker color
                              ),
                              BoxShadow(
                                color: Color(0xffe0e5ec), // background color
                                spreadRadius: 8.0,
                                blurRadius: 12.0,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(50, 50, 50, 10),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 40, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff00BBFB),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xff000000), // darker color
                                    ),
                                    BoxShadow(
                                      color:
                                          Color(0xff404040), // background color
                                      spreadRadius: -5.0,
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  //color: Color(0xff0083fd),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff0083fd),
                                      Color(0xff2394fd),
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(1.0, 0.0),
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp,
                                  ),
                                ),
                                margin: EdgeInsets.only(
                                  bottom: 15.0,
                                ),
                                height: 110,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/calendar_blue.png"),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(
                                              selectedDate != null
                                                  ? selectedDate
                                                  : '-',
                                              //'11',
                                              style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              )),
                                            ),
                                          ),
                                          Text(
                                            selectedDay != null
                                                ? selectedDay.toUpperCase()
                                                : '-',
                                            // '11',
                                            style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            )),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              '$_locality' != ''
                                                  ? '$_locality'
                                                  : '-',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RaisedButton(
                                      elevation: 8,
                                      disabledElevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      color: Color(0xff00bbfb),
                                      disabledColor: Colors.white,
                                      textColor: Colors.white,
                                      disabledTextColor: Colors.grey[400],
                                      highlightElevation: 10,
                                      splashColor: Colors.white30,
                                      onPressed: _pinchinEnabled
                                          ? () => openCameraPage()
                                          : null,
                                      child: Ink(
                                        width: 120,
                                        height: 110,
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 120.0,
                                              minHeight: 110.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Punch in',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                _punchinTime != ''
                                                    ? _punchinTime
                                                    : '-',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      elevation: 8,
                                      disabledElevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      color: Color(0xff00bbfb),
                                      disabledColor: Colors.white,
                                      textColor: Colors.white,
                                      disabledTextColor: Colors.grey[400],
                                      highlightElevation: 10,
                                      splashColor: Colors.white30,
                                      onPressed: _pinchoutEnabled
                                          ? () => openCameraPage()
                                          : null,
                                      child: Ink(
                                        width: 120,
                                        height: 110,
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 120.0,
                                              minHeight: 110.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Punch out',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                _punchoutTime != ''
                                                    ? _punchoutTime
                                                    : '-',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
    );
  }

  Future<void> _goToCurrent() async {
    // print(widget.currLocation.latitude);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(initialPosition));
  }
}
