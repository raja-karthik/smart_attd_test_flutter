import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_flutterapp/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

List<DateTime> presentDates = [];
List<DateTime> earlyDates = [];
List<DateTime> absentDates = [];

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentDate = DateTime.now();
  DateTime selectedMonth;
  var monthAttenceRes = {};
  var punchInOutHistory;
  // bool _loadingIndicator = false;
  var len;
  var len2;
  var len3;
  var totalDaysPresent;
  var totalHrs;

  @override
  void initState() {
    super.initState();
    var currdate = DateTime(currentDate.year, currentDate.month, 1);
    var formatterMonthYear = new DateFormat('MMM y');
    String formattedMonthYear = formatterMonthYear.format(currdate);
    selectedMonth = currdate;
    getMonthAttendance(formattedMonthYear);
  }

  assignEvents() {
    setState(() {
      len = presentDates.length;
      len2 = absentDates.length;
      len3 = earlyDates.length;
      for (int i = 0; i < len; i++) {
        _markedDateMap.add(
          presentDates[i],
          new Event(
            date: presentDates[i],
            title: 'Present event',
            icon: _presentIcon(
              presentDates[i].day.toString(),
            ),
          ),
        );
      }

      for (int i = 0; i < len2; i++) {
        _markedDateMap.add(
          absentDates[i],
          new Event(
            date: absentDates[i],
            title: 'Absent event',
            icon: _absentIcon(
              absentDates[i].day.toString(),
            ),
          ),
        );
      }
      for (int i = 0; i < len3; i++) {
        _markedDateMap.add(
          earlyDates[i],
          new Event(
            date: earlyDates[i],
            title: 'Early event',
            icon: _earlyIcon(
              earlyDates[i].day.toString(),
            ),
          ),
        );
      }
    });
  }

  getMonthAttendance(monthyear) async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/calendar';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var input = {'month': monthyear, 'token': token};
    String jsnstr = jsonEncode(input);
    print('API INPUT $jsnstr');

    var response = await http.post(url, body: input);
    print('Response body: ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');
    if (response.statusCode == 200) {
      if (res['status'] == 'success') {
        if (res['data'] != null) {
          var dates = res['data']['dates'];

          setState(() {
            monthAttenceRes = dates;
            totalDaysPresent = res['data']['days'];
            totalHrs = res['data']['hrs'];
          });

          print('${dates.length}');

          for (var i = 1; i <= dates.length; i++) {
            int j = i;
            int length = j.toString().length;
            var actDate = length == 1 ? '0${j.toString()}' : '${j.toString()}';
            print(dates[actDate]);
            setState(() {
              if (dates[actDate]['t'] == "P") {
                presentDates
                    .add(DateTime(selectedMonth.year, selectedMonth.month, i));
              } else if (dates[actDate]['t'] == "A") {
                absentDates
                    .add(DateTime(selectedMonth.year, selectedMonth.month, i));
              }
            });
          }

          assignEvents();
          print('PRESENT $presentDates');
          print('ABSENT $absentDates');
        }
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
        // _loadingIndicator = false;
      });
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
  void dispose() {
    super.dispose();
  }

  static Widget _presentIcon(String day) => Container(
        decoration: BoxDecoration(
          color: Color(0xff00bbfb),
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

  static Widget _absentIcon(String day) => Container(
        decoration: BoxDecoration(
          color: Colors.orangeAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

  static Widget _earlyIcon(String day) => Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  CalendarCarousel _calendarCarouselNoHeader;

  double cHeight;

  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      height: cHeight * 0.54,
      weekendTextStyle: TextStyle(
        color: Colors.black38,
      ),
      // daysTextStyle: TextStyle(
      //   color: Colors.blueGrey,
      // ),
      weekdayTextStyle: TextStyle(
        color: Colors.black38,
      ),

      headerTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        // backgroundColor: Colors.blue,
      ),
      daysTextStyle: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      todayTextStyle: TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
      onCalendarChanged: (date) {
        setState(() {
          _markedDateMap = new EventList<Event>(
            events: {},
          );
          presentDates = [];
          absentDates = [];
          earlyDates = [];
          selectedMonth = date;
        });

        var formatterMonthYear = new DateFormat('MMM y');
        String formattedMonthYear = formatterMonthYear.format(selectedMonth);
        getMonthAttendance(formattedMonthYear);
      },
      minSelectedDate: DateTime(currentDate.year, currentDate.month - 12, 1),
      maxSelectedDate:
          DateTime(currentDate.year, currentDate.month, currentDate.day),
      todayButtonColor: Color(0xffffffff),
      todayBorderColor: Colors.blue,
      headerTitleTouchable: true,
      markedDatesMap: _markedDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      onDayPressed: (DateTime date, List<Event> event) {
        print('On DAY PRESSED $date - EVENT $event');

        int selectday = date.day;
        var length = selectday.toString().length;
        var actDate = length == 1
            ? '0${selectday.toString()}'
            : '${selectday.toString()}';
        var inoutTime = monthAttenceRes[actDate]['v'];
        print(inoutTime);
        setState(() {
          punchInOutHistory = inoutTime;
        });
      },
      markedDateMoreShowTotal:
          null, // null for not showing hidden events indicator
      markedDateIconBuilder: (event) {
        return event.icon;
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        //elevation: 0,
        backgroundColor: Color(0xff0066ff),
        leading: Container(),
        title: new Text("ATTENDANCE",
            style: GoogleFonts.montserrat(
                textStyle: TextStyle(
              fontWeight: FontWeight.w400,
            ))),
      ),
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
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: 20,
                        ),
                        // width: 100,
                        child: Image.asset('assets/images/stopwatch.png'),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              right: 8,
                              bottom: 10,
                            ),
                            child: Text(
                              'Attendance',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              right: 8,
                              bottom: 5,
                            ),
                            child: Text(
                              totalDaysPresent != null
                                  ? '$totalDaysPresent'
                                  : '0',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              right: 50,
                              bottom: 10,
                            ),
                            child: Text(
                              'Days',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _calendarCarouselNoHeader,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    markerRepresent(Color(0xff00bbfb), "Present"),
                    markerRepresent(Colors.orangeAccent, "Leave"),
                    markerRepresent(Colors.redAccent, "Early"),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: punchInOutHistory != null
                      ? Container(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                width: double.infinity,
                                height: 1,
                                color: Colors.grey[200],
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TIMINGS',
                                      style: GoogleFonts.montserrat(
                                        color: Color(0xff0083fd),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Hours: 0 Hrs',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    for (var data in punchInOutHistory)
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Colors.white,
                                        elevation: 5,
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 20, 10, 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                'IN ${data['in'].toString()}',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'OUT ${data['out'].toString()}',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              )
                            ],
                          ))
                      : Container(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  calendarChange() {}
  Widget markerRepresent(Color color, String data) {
    return new Row(
        // leading: new CircleAvatar(
        //   backgroundColor: color,
        //   radius: 10,
        // ),
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 25, 0),
            child: Text(
              data,
              style: GoogleFonts.montserrat(),
            ),
          )
        ]);
  }
}
