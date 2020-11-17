import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutterapp/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:page_transition/page_transition.dart';
import './home_page.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  var login = LoginPage();
  var splash = SplashPage();

  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => splash,
      '/login': (context) => login,
    },
  ));
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: new Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/images/Smartattendance_board.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Manage your attendance and time tracking in one place.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: 200,
                          height: 65,
                          child: _letsgoBtn(context),
                        ),
                        SizedBox(
                          height: 80,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
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
  }
}

Widget _letsgoBtn(context) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    child: FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      onPressed: () {
        print('Get Started Pressed');
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: LoginPage(),
          ),
        );
      },
      color: Color(0xffFFFFFF),
      child: Text(
        "GET STARTED",
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          //fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xff25BFFA),
          letterSpacing: 2,
        )),
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<LoginModel> _futureLogin;
  int _otpCodeLength = 4;
  bool _isLoadingButton = false;
  bool _isLoadingVerifyButton = false;
  bool _enableButton = false;
  String _otpCode = "";
  bool _isResendSeconds = true;
  bool _enableVerifyBtn = false;

  bool _showOtpContainer = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController verifyCodeController = TextEditingController();

  bool _validateCode = false;
  bool _validateMob = false;
  bool isNextClicked = false;

  Timer _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    _getSignatureCode();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            _isResendSeconds = false;
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  /// get signature code
  _getSignatureCode() async {
    String signature = await SmsRetrieved.getAppSignature();
    print("signature $signature");
  }

  Future<LoginModel> loginUser(String email, String password) async {
    final http.Response response = await http.post(
      'https://reqres.in/api/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    print('RES CODE = ${response.statusCode}');
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      setState(() {
        _isResendSeconds = true;
        startTimer();
      });

      return LoginModel.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  _onSubmitOtp() {
    setState(() {
      _isLoadingButton = !_isLoadingButton;
      _verifyOtpCode();
    });
  }

  _onOtpCallBack(String otpCode, bool isAutofill) {
    setState(() {
      this._otpCode = otpCode;
      if (otpCode.length == _otpCodeLength && isAutofill) {
        _enableButton = false;
        _isLoadingButton = true;
        _verifyOtpCode();
      } else if (otpCode.length == _otpCodeLength && !isAutofill) {
        _enableButton = true;
        _isLoadingButton = false;
      } else {
        _enableButton = false;
      }
    });
  }

  _verifyOtpCode() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loggedin', 'true');
    Timer(Duration(milliseconds: 4000), () {
      setState(() {
        _isLoadingButton = false;
        _enableButton = false;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: MyHomePage(title: 'Home'),
          ),
        );
      });

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
    });
    Timer(Duration(seconds: 30), () {
      setState(() {
        _isResendSeconds = false;
        _enableButton = false;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color gradientStart = Color(0xff25BFFA); //Change start gradient color here
  Color gradientEnd = Color(0xff83c5e0); //Change end gradient color here
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackVerifyPressed,
      child: new Scaffold(
          key: _scaffoldKey,
          // resizeToAvoidBottomInset: false, //when keyboard opens, block the bg
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/onboard_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              // decoration: new BoxDecoration(
              //   gradient: new LinearGradient(
              //       colors: [gradientStart, gradientEnd],
              //       begin: const FractionalOffset(0.2, 0.0),
              //       end: const FractionalOffset(0.5, 0.8),
              //       stops: [0.0, 1.0],
              //       tileMode: TileMode.clamp),
              // ),
              padding: EdgeInsets.symmetric(horizontal: 40),
              // color: Color(0xff25BFFA),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // _logo(),
                  AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      child: _showOtpContainer != true
                          ? Container(
                              child: _loginFields(),
                            )
                          : Container(
                              child: _otpFields(),
                            )),

                  // _futureLogin != null
                  //     ? FutureBuilder<LoginModel>(
                  //         future: _futureLogin,
                  //         builder: (context, snapshot) {
                  //           if (snapshot.hasData) {
                  //             final _token = snapshot.data.token;
                  //             return Container(
                  //               child: _otpFields(),
                  //             );
                  //           } else if (snapshot.hasError) {
                  //             return Container(
                  //               child: Column(
                  //                 children: [
                  //                   _loginFields(),
                  //                   Text("Error"),
                  //                 ],
                  //               ),
                  //             );
                  //           }

                  //           return CircularProgressIndicator();
                  //         },
                  //       )
                  //     : _loginFields(),
                  //_otpFields(),
                  // Container(
                  //   child: RaisedButton(onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       PageTransition(
                  //         type: PageTransitionType.fade,
                  //         child: MyHomePage(title: 'Home'),
                  //         //child: CalendarPage(),
                  //       ),
                  //     );
                  //   }),
                  // ),
                ],
              ),
            ),
          ])),
    );
  }

  Widget _loginFields() {
    return Column(
      children: [
        // _logoText(),
        // SizedBox(
        //   height: 50,
        // ),
        _inputField(
            Icon(Icons.phone_android_rounded,
                size: 18, color: Colors.grey.withOpacity(0.8)),
            'Mobile Number',
            false,
            phoneController,
            10),
        SizedBox(
          height: 20,
        ),
        _inputField2(
            Icon(Icons.account_balance_rounded,
                size: 18, color: Colors.grey.withOpacity(0.8)),
            'Activation Code',
            true,
            verifyCodeController,
            6),
        SizedBox(
          height: 25,
        ),

        _verifyBtn(phoneController, verifyCodeController),
        SizedBox(
          height: 20,
        ),
        _agreeText(),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _agreeText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text:
              'By entering mobile number and activation code, you agree to our ',
          style: GoogleFonts.montserrat(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          children: [
            new TextSpan(
              text: 'Terms and Conditions',
              style: GoogleFonts.montserrat(
                // decoration: TextDecoration.underline,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () => print('Tapped Terms and Condn'),
            ),
            new TextSpan(
              text: ' & ',
              style: GoogleFonts.montserrat(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            new TextSpan(
              text: 'Privacy Policy',
              style: GoogleFonts.montserrat(
                // decoration: TextDecoration.underline,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () => print('Tapped Privacy Policy'),
            ),
          ]),
    );
  }

  Widget _otpFields() {
    return Column(children: [
      _otpHeading(),
      // SizedBox(
      //   height: 10,
      // ),
      // PinCodeTextField(
      //   appContext: context,
      //   length: 4,
      //   onChanged: (value) {
      //     print(value);
      //   },
      //   pinTheme: PinTheme(
      //     shape: PinCodeFieldShape.box,
      //     borderRadius: BorderRadius.circular(10),
      //     fieldHeight: 46,
      //     fieldWidth: 46,
      //     inactiveColor: Colors.blueGrey,
      //     activeColor: Colors.white,
      //     selectedColor: Colors.orange,
      //     inactiveFillColor: Colors.blue[50],
      //     activeFillColor: Colors.blue[300],
      //   ),
      //   onCompleted: (value) {
      //     if (value.length == 4) {
      //       _enableButton = true;
      //       print("Ok OTP");
      //     }
      //   },
      // ),
      TextFieldPin(
        filled: true,
        filledColor: Colors.white,
        codeLength: _otpCodeLength,
        boxSize: 46,
        //filledAfterTextChange: true,
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        filledAfterTextChange: true,

        borderStyle: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        borderStyeAfterTextChange: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        onOtpCallback: (code, isAutofill) => _onOtpCallBack(code, isAutofill),
      ),
      _isResendSeconds == true
          ? Container(
              margin: EdgeInsets.only(
                top: 25,
              ),
              child: Text(
                "Resend OTP in $_start seconds",
                style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            )
          : Container(
              margin: EdgeInsets.only(
                top: 25,
              ),
              child: new GestureDetector(
                onTap: () {
                  print("Clicked resend");
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("OTP sent to ${phoneController.text}"),
                    duration: Duration(milliseconds: 3000),
                  ));
                  setState(() {
                    _start = 30;
                    _isResendSeconds = true;
                    startTimer();
                  });
                },
                child: Text("RESEND OTP",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
      SizedBox(
        height: 25,
      ),
      _loginBtn(),
      SizedBox(
        height: 60,
      ),

      // Container(
      //   width: double.maxFinite,
      //   child: MaterialButton(
      //     onPressed: _enableButton ? _onSubmitOtp : null,
      //     child: _setUpButtonChild(),
      //     color: Colors.blue,
      //     disabledColor: Colors.blue[100],
      //   ),
      // ),
    ]);
  }

  Widget _loginBtn() {
    return Container(
      width: 120.0,
      height: 40.0,
      child: OutlineButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: _enableButton ? _onSubmitOtp : null,
        // setState(() {

        // });

        borderSide: BorderSide(color: Colors.white),
        textColor: Colors.white,
        disabledBorderColor: Colors.white.withOpacity(0.6),
        disabledTextColor: Colors.white.withOpacity(0.6),
        child: _setUpOtpButtonChild(),
      ),
    );
  }

  Widget _setUpOtpButtonChild() {
    if (_isLoadingButton) {
      return Container(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Text(
        "LOGIN",
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          // fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        )),
      );
    }
  }

  Widget _setUpVerifyButtonChild() {
    if (_isLoadingVerifyButton) {
      return Container(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Text(
        "VERIFY",
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          // fontSize: 20,
          fontWeight: FontWeight.w700,

          letterSpacing: 2,
        )),
      );
    }
  }

  Widget _verifyBtn(TextEditingController phoneController,
      TextEditingController verifyCodeController) {
    return Container(
      width: 120.0,
      height: 40.0,
      child: OutlineButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),

        onPressed: _enableVerifyBtn ? () => _onSubmitVerify() : null,
        // onPressed: () {
        //   _onSubmitVerify();
        // },
        borderSide: BorderSide(color: Colors.white),
        textColor: Colors.white,
        disabledBorderColor: Colors.white.withOpacity(0.6),
        disabledTextColor: Colors.white.withOpacity(0.6),
        child: _setUpVerifyButtonChild(),

        // Text(
        //   "VERIFY",
        //   style: GoogleFonts.montserrat(
        //       textStyle: TextStyle(
        //     // fontSize: 20,
        //     fontWeight: FontWeight.w700,
        //     color: Color(0xff25BFFA),
        //     letterSpacing: 2,
        //   )),
        // ),
      ),
    );
  }

  _onSubmitVerify() {
    print("Verify Clicked");
    setState(() {
      _isLoadingVerifyButton = true;
    });

    FocusScope.of(context).requestFocus(new FocusNode());
    _verifyMobNumb();
    // if (!_validateMob && !_validateCode && isNextClicked) {
    //   _showOtpContainer = true;
    // }
    //_verifyMobileCode();
  }

  _verifyMobNumb() async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/login';
    var response = await http.post(url, body: {
      'code': verifyCodeController.text,
      'mobile': phoneController.text
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');
    if (response.statusCode == 200) {
      if (res['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', res['token']);
        setState(() {
          _isLoadingVerifyButton = false;
          _enableVerifyBtn = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('OTP sent to ${phoneController.text}'),
          duration: Duration(milliseconds: 3000),
        ));
        Timer(Duration(milliseconds: 1000), () {
          setState(() {
            _showOtpContainer = true;
            startTimer();
          });
        });
      } else {
        setState(() {
          _isLoadingVerifyButton = false;
          _enableVerifyBtn = true;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Mobile number or Activation code is Incorrect'),
          duration: Duration(milliseconds: 2000),
        ));
      }
    } else {
      setState(() {
        _isLoadingVerifyButton = false;
        _enableVerifyBtn = true;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Service Unreachable'),
        duration: Duration(milliseconds: 2000),
      ));
    }
  }

  Future<bool> _onBackVerifyPressed() {
    if (_showOtpContainer) {
      setState(() {
        _showOtpContainer = false;
      });
    } else {
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
    }
  }

  _verifyMobileCode() {
    print('GET OTP - Next Pressed');
    setState(() {
      if (!_validateMob && !_validateCode && isNextClicked) {
        _futureLogin = loginUser(
          phoneController.text,
          verifyCodeController.text,
        );
      }
      isNextClicked = true;
    });

    // print("Print Login $_futureLogin");

    // if (_futureLogin != null) {
    //   Navigator.push(
    //     context,
    //     PageTransition(
    //       type: PageTransitionType.leftToRight,
    //       child: OnBoardingPage(),
    //     ),
    //   );
    // }
  }

  Widget _inputField(Icon prefixIcon, String hintText, bool isCode,
      TextEditingController controller, int maxlength) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: TextField(
        controller: controller,
        //obscureText: isCode,

        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxlength),
        ],
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          // fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          //Color(0xff000912),
        )),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          errorText: isNextClicked
              ? isCode
                  ? validateCode(controller) != null
                      ? validateCode(controller)
                      : null
                  : validateMobile(controller) != null
                      ? validateMobile(controller)
                      : null
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: 50,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white.withOpacity(0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white.withOpacity(0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        onChanged: (text) {
          setState(() {
            if (text.length == 10 && verifyCodeController.text.length == 6) {
              _enableVerifyBtn = true;
              //  print(_enableVerifyBtn);
            } else {
              _enableVerifyBtn = false;
            }
          });
        },
      ),
    );
  }

  Widget _inputField2(Icon prefixIcon, String hintText, bool isCode,
      TextEditingController controller, int maxlength) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: TextField(
        controller: controller,
        //obscureText: isCode,

        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxlength),
        ],
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          // fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          //Color(0xff000912),
        )),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          errorText: isNextClicked
              ? isCode
                  ? validateCode(controller) != null
                      ? validateCode(controller)
                      : null
                  : validateMobile(controller) != null
                      ? validateMobile(controller)
                      : null
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: 50,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white.withOpacity(0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white.withOpacity(0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        onChanged: (text) {
          setState(() {
            if (phoneController.text.length == 10 && text.length == 6) {
              _enableVerifyBtn = true;
              //  print(_enableVerifyBtn);
            } else {
              _enableVerifyBtn = false;
            }
          });
        },
      ),
    );
  }

  String validateMobile(TextEditingController controller) {
    String value = controller.text;
    if (value.length < 10) {
      _validateMob = true;
      return "Mobile number must be 10 digits";
    }
    _validateMob = false;
    return null;
  }

  String validateCode(TextEditingController controller) {
    String value = controller.text;
    if (value.length < 6) {
      _validateCode = true;
      return "Activation Code must be 6 digits";
    }
    _validateCode = false;
    return null;
  }

  Widget _logoText() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 50),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              )),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Verify to get One Time Password',
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              )),
            ),
          ],
        ));
  }

  Widget _otpHeading() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 50),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text(
            //   'OTP',
            //   textAlign: TextAlign.left,
            //   style: GoogleFonts.montserrat(
            //       textStyle: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.w400,
            //     color: Colors.white,
            //   )),
            // ),
            // SizedBox(
            //   height: 5,
            // ),
            Text(
              'Enter the 4 digit OTP sent to ${phoneController.text}',
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              )),
            ),
          ],
        ));
  }

  Widget _logo() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 100, 0, 50),
      child: Stack(
        children: [
          Positioned(
            child: Container(
              width: 100,
              height: 122,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/smart_attendance.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    launchPage();
  }

  launchPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loggedin = prefs.getString('loggedin');
    print('LOGGED IN => $loggedin');
    Future.delayed(Duration(seconds: 3), () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => LoginPage(),
      //   ),
      // );
      //Navigator.pushNamed(context, '/login');
      if (loggedin == 'true') {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: MyHomePage(title: 'Home'),
          ),
        );
      } else {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: LoginPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 206,
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/smart_attendance.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// Future<LoginModel> loginUser(String email, String password) async {
//   final http.Response response = await http.post(
//     'https://reqres.in/api/login',
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'email': email,
//       'password': password,
//     }),
//   );
//   print('RES CODE = ${response.statusCode}');
//   if (response.statusCode == 200) {
//     // If the server did return a 201 CREATED response,
//     // then parse the JSON.
//     return LoginModel.fromJson(jsonDecode(response.body));
//   } else {
//     // If the server did not return a 201 CREATED response,
//     // then throw an exception.
//     throw Exception('Failed to load album');
//   }
// }

// Future<http.Response> postRequest(data) async {
//   var url = 'https://reqres.in/api/login';

//   //encode Map to JSON
//   var body = json.encode(data);

//   var response = await http.post(url,
//       headers: {"Content-Type": "application/json"}, body: body);
//   var result = jsonDecode(response.body);
//   print("${response.statusCode}");
//   print("${result.token}");
//   return response;
// }

// class _HomePageState extends State<HomePage> {
//   Future<LoginModel> _futureLogin;
//   Future<RegisterModel> _futureRegister;

//   int _otpCodeLength = 4;
//   bool _isLoadingButton = false;
//   bool _enableButton = false;
//   String _otpCode = "";
//   Position currLocation;

//   final _scaffoldKey = GlobalKey<ScaffoldState>();

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   String _imagePath;

//   @override
//   void initState() {
//     super.initState();

//     _getPermission();
//   }

//   _getPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     print('Location Permission =>  $permission');
//     if (permission == LocationPermission.denied) {
//       await Geolocator.requestPermission();
//     }
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     print(position);
//     currLocation = position;
//   }

//   _verifyOtpCode() {
//     FocusScope.of(context).requestFocus(new FocusNode());
//     Timer(Duration(milliseconds: 4000), () {
//       setState(() {
//         _isLoadingButton = false;
//         _enableButton = false;
//       });

//       _scaffoldKey.currentState.showSnackBar(
//           SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Text('Flutter App'),
//       ),
//       body: Stack(
//         children: <Widget>[
//           _imagePath != null
//               ? capturedImageWidget(_imagePath)
//               : noImageWidget(),
//           // fabWidget2(),
//           // fabWidget(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         elevation: 10.0, //Shadow of button
//         onPressed: openCamera,
//         child: Icon(
//           Icons.photo_camera,
//           color: Colors.white,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

//   Widget noImageWidget() {
//     return SizedBox.expand(
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.all(24),
//           child: (_futureRegister == null && _futureLogin == null)
//               ? Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     TextField(
//                       controller: emailController,
//                       decoration: InputDecoration(hintText: 'Email'),
//                     ),
//                     TextField(
//                       controller: passwordController,
//                       decoration: InputDecoration(hintText: 'Password'),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: <Widget>[
//                         ElevatedButton(
//                           child: Text('Register'),
//                           onPressed: () {
//                             setState(() {
//                               _futureRegister = registerUser(
//                                 emailController.text,
//                                 passwordController.text,
//                               );
//                             });
//                           },
//                         ),
//                         ElevatedButton(
//                           child: Text('Login'),
//                           onPressed: () {
//                             setState(() {
//                               _futureLogin = loginUser(
//                                 emailController.text,
//                                 passwordController.text,
//                               );
//                             });
//                             openMap();
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 )
//               : _futureLogin == null
//                   ? FutureBuilder<RegisterModel>(
//                       future: _futureRegister,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return Container(
//                             child: Column(
//                               children: [
//                                 Text('Registered ID: ${snapshot.data.id}'),
//                                 Text(
//                                     'Registered current Location: $currLocation'),
//                               ],
//                             ),
//                           );
//                         } else if (snapshot.hasError) {
//                           return Text("${snapshot.error}");
//                         }

//                         return CircularProgressIndicator();
//                       },
//                     )
//                   : FutureBuilder<LoginModel>(
//                       future: _futureLogin,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return Text('Token: ${snapshot.data.token}');
//                         } else if (snapshot.hasError) {
//                           return Text("${snapshot.error}");
//                         }

//                         return CircularProgressIndicator();
//                       },
//                     ),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         TextFieldPin(
//           filled: true,
//           filledColor: Colors.grey[100],
//           codeLength: _otpCodeLength,
//           boxSize: 48,
//           onOtpCallback: (code, isAutofill) => _onOtpCallBack(code, isAutofill),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Container(
//           width: double.maxFinite,
//           child: MaterialButton(
//             onPressed: _enableButton ? _onSubmitOtp : null,
//             child: _setUpButtonChild(),
//             color: Colors.blue,
//             disabledColor: Colors.blue[100],
//           ),
//         ),
//         Container(
//           child: Icon(
//             Icons.image,
//             color: Colors.grey,
//           ),
//           width: 60.0,
//           height: 60.0,
//         ),
//         Container(
//           margin: EdgeInsets.only(top: 8.0),
//           child: Text(
//             'No Image Captured',
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 16.0,
//             ),
//           ),
//         ),
//       ],
//     ));
//   }

//   Widget _setUpButtonChild() {
//     if (_isLoadingButton) {
//       return Container(
//         width: 19,
//         height: 19,
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     } else {
//       return Text(
//         "Verify",
//         style: TextStyle(color: Colors.white),
//       );
//     }
//   }

//   Widget capturedImageWidget(String imagePath) {
//     final bytes = Io.File(imagePath).readAsBytesSync();
//     String img64 = base64Encode(bytes);
//     print(img64.substring(0, 100));

//     return Container(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20.0),
//             // child: Image.file(
//             // Io.File(
//             //   imagePath,
//             // ),
//             //   height: 200,
//             //   width: 200,
//             //   fit: BoxFit.fill,
//             // ),
//             child: Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage(imagePath), fit: BoxFit.cover),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     // SizedBox.expand(
//     //   child: Image.file(
//     //     Io.File(
//     //       imagePath,
//     //     ),
//     //     height: 100,
//     //     width: 100,
//     //     fit: BoxFit.fill,
//     //   ),
//     // );
//   }

//   Widget fabWidget2() {
//     return Positioned(
//       bottom: 30.0,
//       left: 16.0,
//       child: FloatingActionButton(
//         heroTag: "btn1",
//         onPressed: openMap,
//         child: Icon(
//           Icons.location_pin,
//           color: Colors.white,
//         ),
//         backgroundColor: Colors.blueAccent,
//       ),
//     );
//   }

//   openMap() {
//     print("Open Map");
//     //  Navigator.pushNamed(context, '/map');
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapPage(
//           currLocation: currLocation,
//         ),
//       ),
//     );
//   }

//   Widget fabWidget() {
//     return Positioned(
//       bottom: 30.0,
//       right: 16.0,
//       child: FloatingActionButton(
//         heroTag: "btn2",
//         onPressed: openCamera,
//         child: Icon(
//           Icons.photo_camera,
//           color: Colors.white,
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   Future openCamera() async {
//     availableCameras().then((cameras) async {
//       final imagePath = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CameraPage(cameras),
//         ),
//       );
//       setState(() {
//         _imagePath = imagePath;
//       });
//     });
//   }

//   // Future openCamera2() async {
//   //   availableCameras().then((cameras) async {
//   //     final imagePath = await Navigator.pushNamed(context, '/camera');
//   //     setState(() {
//   //       _imagePath = imagePath;
//   //     });
//   //   });
//   // }
// }

// class CameraApp extends StatefulWidget {
//   CameraApp({Key key}) : super(key: key);
//   @override
//   _CameraAppState createState() => _CameraAppState();
// }

// class _CameraAppState extends State<CameraApp> {
//   String imagePath;
//   bool _toggleCamera = false;
//   CameraController controller;
//   Future<void> controllerInizializer;

//   Future<CameraDescription> getCamera() async {
//     final c = await availableCameras();
//     return c.last;
//   }

//   @override
//   void initState() {
//     onCameraSelected(cameras[0]);
//     super.initState();

//     getCamera().then((camera) {
//       setState(() {
//         controller = CameraController(camera, ResolutionPreset.medium);
//         controllerInizializer = controller.initialize();
//       });
//     });

//     // controller = CameraController(cameras[0], ResolutionPreset.medium);
//     // controller.initialize().then((_) {
//     //   if (!mounted) {
//     //     return;
//     //   }
//     //   setState(() {});
//     // });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return Stack(
//       children: <Widget>[
//         Positioned.fill(
//             child: FutureBuilder(
//                 future: controllerInizializer,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return CameraPreview(controller);
//                   } else {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                 })),
//         Positioned.fill(
//             child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             //leading: Icon(Icons.settings),
//           ),
//           body: Container(
//             child: Stack(
//               children: <Widget>[
//                 Positioned(
//                     bottom: 50,
//                     right: 40,
//                     left: 50,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: <Widget>[
//                         Container(
//                           height: 50,
//                           child: Icon(
//                             Icons.cached,
//                             color: Colors.transparent,
//                           ),
//                         ),
//                         GestureDetector(
//                           child: Container(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(30),
//                                 ),
//                               ),
//                             ),
//                             height: 60,
//                             width: 60,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(30),
//                               ),
//                               border: Border.all(
//                                 width: 7,
//                                 color: Colors.white.withOpacity(.5),
//                               ),
//                             ),
//                           ),
//                           onTap: () {
//                             captureImage();
//                           },
//                         ),
//                         GestureDetector(
//                           child: Container(
//                             child: Icon(
//                               Icons.cached,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           onTap: () {
//                             if (!_toggleCamera) {
//                               onCameraSelected(cameras[1]);
//                               setState(() {
//                                 _toggleCamera = true;
//                               });
//                             } else {
//                               onCameraSelected(cameras[0]);
//                               setState(() {
//                                 _toggleCamera = false;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ))
//               ],
//             ),
//           ),
//         ))
//       ],
//     );
//     //   return AspectRatio(
//     //       aspectRatio: controller.value.aspectRatio,
//     //       child: CameraPreview(controller));
//     // }
//   }

//   void onCameraSelected(CameraDescription cameraDescription) async {
//     if (controller != null) await controller.dispose();
//     controller = CameraController(cameraDescription, ResolutionPreset.medium);

//     controller.addListener(() {
//       if (mounted) setState(() {});
//       if (controller.value.hasError) {
//         showMessage('Camera Error: ${controller.value.errorDescription}');
//       }
//     });

//     try {
//       await controller.initialize();
//     } on CameraException catch (e) {
//       showException(e);
//     }

//     if (mounted) setState(() {});
//   }

//   String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

//   void captureImage() {
//     takePicture().then((String filePath) {
//       if (mounted) {
//         setState(() {
//           imagePath = filePath;
//         });
//         if (filePath != null) {
//           showMessage('Picture saved to $filePath');
//           setCameraResult();
//         }
//       }
//     });
//   }

//   void setCameraResult() {
//     Navigator.pop(context, imagePath);
//   }

//   Future<String> takePicture() async {
//     if (!controller.value.isInitialized) {
//       showMessage('Error: select a camera first.');
//       return null;
//     }
//     final Io.Directory extDir = await getApplicationDocumentsDirectory();
//     final String dirPath = '${extDir.path}/Images';
//     await new Io.Directory(dirPath).create(recursive: true);
//     final String filePath = '$dirPath/${timestamp()}.jpg';

//     if (controller.value.isTakingPicture) {
//       // A capture is already pending, do nothing.
//       return null;
//     }

//     try {
//       await controller.takePicture(filePath);
//     } on CameraException catch (e) {
//       showException(e);
//       return null;
//     }
//     return filePath;
//   }

//   void showException(CameraException e) {
//     logError(e.code, e.description);
//     showMessage('Error: ${e.code}\n${e.description}');
//   }

//   void showMessage(String message) {
//     print(message);
//   }

//   void logError(String code, String message) =>
//       print('Error: $code\nMessage: $message');
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // leading: IconButton(
//         //     icon: Icon(Icons.menu),
//         //     onPressed: () {
//         //       print('Icon Buuton Clicked');
//         //     }),
//         title: Text('Flutter App'),
//         actions: <Widget>[
//           IconButton(icon: Icon(Icons.search), onPressed: () {}),
//           IconButton(icon: Icon(Icons.more_vert), onPressed: () {})
//         ],
//         // flexibleSpace: Icon(Icons.camera, color: Colors.white),
//       ),
//       body: Center(
//         child: Text(
//           'Karthik King',
//           style: TextStyle(color: Colors.red, fontSize: 22.0),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         elevation: 10.0, //Shadow of button
//         onPressed: () {
//           print('Clicked FAB');
//         },
//         child: Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       drawer: Drawer(
//         elevation: 12.0, //shadow of side bar
//         child: Column(
//           children: <Widget>[
//             UserAccountsDrawerHeader(
//               accountName: Text('Karthik'),
//               accountEmail: Text('karthik@gmail.com'),
//               currentAccountPicture: CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/vj.jpg'),
//               ),
//               otherAccountsPictures: <Widget>[
//                 CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     'A',
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 22.0),
//                   ),
//                 )
//               ],
//             ),
//             ListTile(
//               leading: Icon(Icons.mail_outline),
//               title: Text('All Inboxes'),
//             ),
//             Divider(
//               height: 0.1,
//             ),
//             ListTile(
//               leading: Icon(Icons.inbox_outlined),
//               title: Text('Primary'),
//             ),
//             Divider(
//               height: 0.1,
//             ),
//             ListTile(
//               leading: Icon(Icons.people_alt_outlined),
//               title: Text('Social'),
//             ),
//             Divider(
//               height: 0.1,
//             ),
//             ListTile(
//               leading: Icon(Icons.local_offer_outlined),
//               title: Text('Promotions'),
//             ),
//             Divider(
//               height: 0.1,
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         fixedColor: Colors.green,
//         items: [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined), title: Text('Home')),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.search), title: Text('Search')),
//           BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Add'))
//         ],
//         onTap: (int index) {
//           print(index);
//         },
//       ),
//     );
//   }
// }

// class FirstPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text('User Details', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.red,
//           centerTitle: true,
//         ),
//         body: Padding(
//           padding: EdgeInsets.fromLTRB(30, 40, 30, 50),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Center(
//                 child: CircleAvatar(
//                   backgroundImage: AssetImage('assets/images/vj.jpg'),
//                   backgroundColor: Colors.white,
//                   radius: 50,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'Name',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     color: Colors.red),
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'Karthik',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     color: Colors.black),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'Type',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     color: Colors.red),
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'Staff',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     color: Colors.black),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'Email',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     color: Colors.red),
//               ),
//               SizedBox(height: 6),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: <Widget>[
//                   Icon(
//                     Icons.email_outlined,
//                     color: Colors.grey,
//                     size: 16,
//                   ),
//                   SizedBox(width: 6),
//                   Text(
//                     'karthik@gmail.com',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: Colors.black,
//                       letterSpacing: .2,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'Phone Number',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     color: Colors.red),
//               ),
//               SizedBox(height: 6),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: <Widget>[
//                   Icon(
//                     Icons.call_outlined,
//                     color: Colors.grey,
//                     size: 16,
//                   ),
//                   SizedBox(width: 6),
//                   Text(
//                     '+91 88078 81234',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: Colors.black,
//                       letterSpacing: .2,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         )
//         // Center(
//         //   child: RaisedButton(
//         //     child: Text('Go to List Page', style: TextStyle(color: Colors.white)),
//         //     color: Colors.amber,
//         //     onPressed: () {
//         //       Navigator.pushNamed(context, '/second');
//         //     },
//         //   ),
//         // ),
//         );
//   }
// }

// class RandomWords extends StatefulWidget {
//   @override
//   _RandomWordsState createState() => _RandomWordsState();
// }

// class _RandomWordsState extends State<RandomWords> {
//   final _suggestions = <WordPair>[];
//   final _saved = Set<WordPair>();
//   final _biggerFont = TextStyle(fontSize: 18.0);
//   @override
//   Widget build(BuildContext context) {
//     // final wordPair = WordPair.random();
//     // return Text(wordPair.asPascalCase);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Flutter App', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.amberAccent,
//         actions: [
//           IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
//         ],
//       ),
//       body: _buildSuggestions(),
//     );
//   }

//   Widget _buildSuggestions() {
//     return ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemBuilder: /*1*/ (context, i) {
//           if (i.isOdd) return Divider(); /*2*/

//           final index = i ~/ 2; /*3*/
//           if (index >= _suggestions.length) {
//             _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//           }
//           return _buildRow(_suggestions[index]);
//         });
//   }

//   Widget _buildRow(WordPair pair) {
//     final alreadySaved = _saved.contains(pair);
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       trailing: Icon(
//         alreadySaved ? Icons.favorite : Icons.favorite_border,
//         color: alreadySaved ? Colors.red : null,
//       ),
//       onTap: () {
//         setState(() {
//           if (alreadySaved) {
//             _saved.remove(pair);
//           } else {
//             _saved.add(pair);
//           }
//         });
//       },
//     );
//   }

//   void _pushSaved() {
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         // NEW lines from here...

//         builder: (BuildContext context) {
//           final tiles = _saved.map(
//             (WordPair pair) {
//               return ListTile(
//                 title: Text(
//                   pair.asPascalCase,
//                   style: _biggerFont,
//                 ),
//               );
//             },
//           );
//           final divided = ListTile.divideTiles(
//             context: context,
//             tiles: tiles,
//           ).toList();

//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Saved Suggestions'),
//             ),
//             body: ListView(children: divided),
//           );
//         }, // ...to here.
//       ),
//     );
//   }
// }
