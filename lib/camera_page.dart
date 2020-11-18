import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/home_page.dart';
import 'package:my_first_flutterapp/main.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraPage(this.cameras);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String imagePath;
  bool _toggleCamera = true;
  CameraController controller;
  bool _showLoading = false;

  @override
  void initState() {
    onCameraSelected(widget.cameras[1]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
        body: _showLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Transform.scale(
                    scale: controller.value.aspectRatio / deviceRatio,
                    child: Center(
                      child: Container(
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height / 10,
                          left: size.width / 10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                left: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height / 10,
                          right: size.width / 10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: (size.height / 10) + 100,
                          left: size.width / 10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                left: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: (size.height / 10) + 100,
                          right: size.width / 10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin:
                                EdgeInsets.only(top: (size.height / 10) + 25),
                            padding: EdgeInsets.fromLTRB((size.width / 10) + 30,
                                0, (size.width / 10) + 30, 0),
                            child: Text(
                              'Position yourself in the center with a smile',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dancingScript(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 18,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(
                                bottom: (size.height / 10) + 125),
                            padding: EdgeInsets.fromLTRB((size.width / 10) + 30,
                                0, (size.width / 10) + 30, 0),
                            child: Text(
                              'Click the capture icon when you are ready',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dancingScript(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 18,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 120.0,
                      padding: EdgeInsets.fromLTRB(45.0, 20.0, 45.0, 20.0),
                      color: Color.fromRGBO(00, 00, 00, 0.5),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
                                onTap: () {
                                  _captureImage();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    'assets/images/shutter_1.png',
                                    width: 72.0,
                                    height: 72.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
                                onTap: () {
                                  if (!_toggleCamera) {
                                    onCameraSelected(widget.cameras[1]);
                                    setState(() {
                                      _toggleCamera = true;
                                    });
                                  } else {
                                    onCameraSelected(widget.cameras[0]);
                                    setState(() {
                                      _toggleCamera = false;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    'assets/images/switch_camera_3.png',
                                    color: Colors.grey[200],
                                    width: 42.0,
                                    height: 42.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
    //Transform.scale
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          _showLoading = true;
          imagePath = filePath;
        });
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          // setCameraResult();
          final bytes = Io.File(imagePath).readAsBytesSync();
          String imgBase64 = base64Encode(bytes);
          _saveAttendance(imgBase64);
        }
      }
    });
  }

  _saveAttendance(imgBase64) async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/attendance';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var latitude = prefs.getString('currentLatitude');
    var longitute = prefs.getString('currentLongitude');
    var datenow = new DateTime.now();

    var input = {
      'profile': 'data:image/jpeg;base64, $imgBase64',
      'time': datenow.toString(),
      'token': token,
      'temp': '0',
      'lat': latitude,
      'lng': longitute
    };
    //String jsnstr = jsonEncode(input);
    print('API INPUT $imgBase64');
    print(
        'API INPUT ${input['token']} - ${input['time']} - ${input['temp']} - ${input['lat']} - ${input['lng']}');

    var response = await http.post(url, body: input);

    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');
    if (response.statusCode == 200) {
      if (res['status'] == 'success') {
        // if (res['data'] != null) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: MyHomePage(title: 'Home'),
          ),
        );
        // }
      } else {
        if (res['token_invalid'] == 'true') {
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
                        Navigator.of(context).pop(false);
                        setState(() {
                          _showLoading = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "RETAKE",
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

  void setCameraResult() {
    Navigator.pop(context, imagePath);
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }
    final Io.Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Images';
    await new Io.Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  void showException(CameraException e) {
    logError(e.code, e.description);
    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');
}
