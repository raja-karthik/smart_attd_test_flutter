import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutterapp/data.dart';
import 'package:my_first_flutterapp/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutterapp/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<ShouldOverrideUrlLoadingAction> shouldOverrideUrlLoading(
      ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
    print("\n\n override ${shouldOverrideUrlLoadingRequest.url}\n\n");
    return ShouldOverrideUrlLoadingAction.ALLOW;
  }

  @override
  void onLoadResource(LoadedResource response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var login = LoginPage();
  var splash = SplashPage();

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
  List<SliderModel> mySLides = new List<SliderModel>();
  int slideIndex = 0;
  PageController controller;

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mySLides = getSlides();
    controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: PageView(
                  controller: controller,
                  onPageChanged: (index) {
                    setState(() {
                      slideIndex = index;
                    });
                  },
                  children: <Widget>[
                    SlideTile(
                      imagePath: mySLides[0].getImageAssetPath(),
                      title: mySLides[0].getTitle(),
                      desc: mySLides[0].getDesc(),
                    ),
                    SlideTile(
                      imagePath: mySLides[1].getImageAssetPath(),
                      title: mySLides[1].getTitle(),
                      desc: mySLides[1].getDesc(),
                    ),
                    SlideTile(
                      imagePath: mySLides[2].getImageAssetPath(),
                      title: mySLides[2].getTitle(),
                      desc: mySLides[2].getDesc(),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: slideIndex != 2
                    ? Container(
                        // color: Colors.transparent,
                        //margin: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                controller.animateToPage(2,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              },
                              splashColor: Colors.blue[50],
                              child: Text(
                                "SKIP",
                                style: TextStyle(
                                    color: Color(0xFF0074E4),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  for (int i = 0; i < 3; i++)
                                    i == slideIndex
                                        ? _buildPageIndicator(true)
                                        : _buildPageIndicator(false),
                                ],
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                print("this is slideIndex: $slideIndex");
                                controller.animateToPage(slideIndex + 1,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              },
                              splashColor: Colors.blue[50],
                              child: Text(
                                "NEXT",
                                style: TextStyle(
                                    color: Color(0xFF0074E4),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          print("Get Started Now");
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: LoginPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: Platform.isIOS ? 70 : 50,
                          color: Colors.blue,
                          alignment: Alignment.center,
                          child: Text(
                            "GET STARTED NOW",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          //bottomSheet:
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

class SlideTile extends StatelessWidget {
  String imagePath, title, desc;

  SlideTile({this.imagePath, this.title, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      // alignment: Alignment.center,
      // child:
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),

      // Column(
      //   // mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Image.asset(
      //       imagePath,
      //       fit: BoxFit.cover,
      //     ),
      //     // SizedBox(
      //     //   height: 40,
      //     // ),
      //     // Text(
      //     //   title,
      //     //   textAlign: TextAlign.center,
      //     //   style: GoogleFonts.montserrat(
      //     //       fontWeight: FontWeight.w500, fontSize: 20),
      //     // ),
      //     // SizedBox(
      //     //   height: 20,
      //     // ),
      //     // Text(
      //     //   desc,
      //     //   textAlign: TextAlign.center,
      //     //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //     // )
      //   ],
      // ),
    );
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
  final MyInAppBrowser browser = new MyInAppBrowser();
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
      });
      startTimer();

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
    });
    _verifyOtpCode();
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
      });
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: MyHomePage(title: 'Home'),
        ),
      );

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
      child: SafeArea(
        child: new Scaffold(
            key: _scaffoldKey,
            // resizeToAvoidBottomInset: false, //when keyboard opens, block the bg
            body: Stack(children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/login_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
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
                  ],
                ),
              ),
            ])),
      ),
    );
  }

  Widget _loginFields() {
    return Column(
      children: [
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
                ..onTap = () {
                  print('Tapped Terms and Condn');
                  widget.browser.openUrl(
                    url: 'https://www.vaango.co/tnc/',
                    options: InAppBrowserClassOptions(
                      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          useOnLoadResource: true,
                        ),
                      ),
                    ),
                  );
                },
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
                ..onTap = () {
                  print('Tapped Privacy Policy');
                  widget.browser.openUrl(
                    url: 'https://www.vaango.co/privacy/',
                    options: InAppBrowserClassOptions(
                      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          useOnLoadResource: true,
                        ),
                      ),
                    ),
                  );
                },
            ),
          ]),
    );
  }

  Widget _otpFields() {
    return Column(children: [
      _otpHeading(),
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
                  });
                  startTimer();
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
        borderSide: BorderSide(color: Colors.white),
        textColor: Colors.white,
        disabledBorderColor: Colors.white.withOpacity(0.6),
        disabledTextColor: Colors.white.withOpacity(0.6),
        child: _setUpVerifyButtonChild(),
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
        var details = res['details'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', res['token']);
        prefs.setString('name', details['name']);
        prefs.setString('profile_url', details['profile']);
        String img64;
        http.Response response = await http.get(
          details['logo'],
        );
        if (mounted) {
          img64 = base64Encode(response.bodyBytes);
        }

        prefs.setString('logo_base64', img64);
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
          });
          startTimer();
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
  var decodedBytes;
  var loggedin;
  @override
  void initState() {
    super.initState();
    getLogoImage();
    launchPage();
  }

  getLogoImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var base64Str = prefs.getString('logo_base64');
    if (base64Str != null) {
      setState(() {
        loggedin = prefs.getString('loggedin');
        decodedBytes = base64Decode(base64Str);
      });
    }
  }

  launchPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedin = prefs.getString('loggedin');
    print('LOGGED IN => $loggedin');
    Future.delayed(Duration(seconds: 6), () {
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
            child: OnBoardingPage(),
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
            // width: 206,
            // height: 250,
            child: loggedin == 'true'
                ? Image.memory(
                    decodedBytes,
                    width: 220,
                  )
                : Image.asset(
                    'assets/images/smart_attendance.png',
                    fit: BoxFit.cover,
                    width: 220,
                  )),
      ),
    );
  }
}
