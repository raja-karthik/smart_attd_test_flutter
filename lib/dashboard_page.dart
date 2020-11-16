import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './map_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DashboardHomePage extends StatefulWidget {
  @override
  _DashboardHomePageState createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List months = [];
  List attendance = [];
  var _currentIndex;
  var _totalIndex;
  var attendanceFinal;
  // List<String> month;
  DateTime currentDate = DateTime.now();
  List<DateTime> selectedList = [];

  @override
  void initState() {
    super.initState();
    var currdate = DateTime(currentDate.year, currentDate.month, 1);
    var formatterMonthYear = new DateFormat('MMM y');
    String formattedMonthYear = formatterMonthYear.format(currdate);
    getMonths();

    _currentIndex = months.length - 1;

    loadDatesOfMonth();

    getAttendance(formattedMonthYear);

    _tabController = new TabController(
      vsync: this,
      length: months.length,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() async {
    setState(() {
      _currentIndex = _tabController.index;
      var monthyear = months[_currentIndex]['monthYear'];

      loadDatesOfMonth();
      getAttendance(monthyear);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMonth', months[_currentIndex]['month']);
  }

  getMonths() {
    setState(() {
      for (var i = 11; i >= 0; i--) {
        var lastMonth = DateTime(currentDate.year, currentDate.month - i, 1);
        var formatterMonth = new DateFormat('MMM');
        var formatterMonthYear = new DateFormat('MMM y');
        String formattedMonth = formatterMonth.format(lastMonth);
        String formattedMonthYear = formatterMonthYear.format(lastMonth);
        print('$formattedMonthYear');
        months.add({'month': formattedMonth, 'monthYear': formattedMonthYear});
      }
      _totalIndex = months.length - 1;
    });
  }

  loadDatesOfMonth() {
    final today = DateTime.now();
    var startDate;
    var endDate;

    if (_currentIndex == _totalIndex) {
      startDate = DateTime(
          today.year, today.month, 1); // first date of the current month
      endDate = DateTime(today.year, today.month,
          today.day); // current date of the current month
    } else {
      var i = _totalIndex - _currentIndex;
      startDate =
          DateTime(today.year, today.month - i, 1); // first date of the month
      endDate =
          DateTime(today.year, today.month - i + 1, 0); //last date of the month
    }

    List<DateTime> selectedMonthDays = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      selectedMonthDays.add(startDate.add(Duration(days: i)));
    }
    selectedList = selectedMonthDays;
    if (_currentIndex == _totalIndex) {
      List<DateTime> descDate = [];
      DateFormat format = DateFormat("yyyy-MM-dd");

      for (int i = 0; i < selectedMonthDays.length; i++) {
        descDate.add(format.parse(selectedMonthDays[i].toString()));
      }
      descDate.sort((b, a) => a.compareTo(b));
      selectedList = descDate;
    }
  }

  getAttendance(monthyear) async {
    var url = 'https://smartattendance.vaango.co/api/v0/employee/monthly';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var input = {'month': monthyear, 'token': token};
    String jsnstr = jsonEncode(input);
    print('API INPUT $jsnstr');

    var response = await http.post(url, body: input);

    print('Response body: ${response.body}');
    Map<String, dynamic> res = jsonDecode(response.body);
    print('After Decode $res');
    if (response.statusCode == 200) {
      setState(() {
        if (res['status'] == 'success') {
          if (res['data'] != null) {
            // List newListTiming = [];
            // print('PRRRRRRRR $attdTiming');
            attendanceFinal = groupBy(res['data'], (obj) => obj['dt']);

            print('GROUP BY $attendanceFinal');

            // groupByDate.forEach((date, list) {
            //   var aaa = {'$date': []};

            //   // Group
            //   list.forEach((listItem) {
            //     aaa['$date'].add(listItem);
            //   });
            //   newListTiming.add(aaa);
            // });
            // print('LISSSSSTTT $newListTiming');
          }
        } else {}
      });
    } else {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: months.length,
      child: Scaffold(
          appBar: AppBar(
            // elevation: 0,
            backgroundColor: Color(0xff0066ff),
            // leading: Icon(Icons.account_circle),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.account_circle, size: 32.0),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Karthik",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ],
            ),
            titleSpacing: 0.0,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
                child: Container(
                  color: Color(0xff0083FD),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.4),
                    indicatorColor: Colors.white,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.0, color: Colors.white),
                      insets: EdgeInsets.symmetric(horizontal: 5.0),
                    ),
                    tabs: List<Widget>.generate(months.length, (int index) {
                      // print(categories[index]);
                      return new Tab(
                          child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text(
                          months[index]['month'],
                          style: GoogleFonts.montserrat(),
                        ),
                      ));
                    }),
                  ),
                ),
                preferredSize: Size.fromHeight(50.0)),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.notifications),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage("assets/images/dashboard_bg.png"),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              new TabBarView(
                controller: _tabController,
                children: List<Widget>.generate(months.length, (int index) {
                  // print(categories[index]);
                  // var monthAttd = attendance[index];
                  return new Container(
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                        itemCount: selectedList.length,
                        itemBuilder: (BuildContext context, int numb) {
                          DateTime date =
                              DateTime.parse(selectedList[numb].toString());
                          var formatdt = new DateFormat('dd');
                          var formatday = new DateFormat('EEE');
                          var formateddt = formatdt.format(date);
                          var formatedday = formatday.format(date);

                          var dt = new DateFormat('yMd').format(currentDate);
                          var dt2 = new DateFormat('yMd').format(date);

                          var todayBg = dt.compareTo(dt2); //if 0

                          var _punchin = '-', _punchout = '-';
                          var sArr;
                          if (attendanceFinal != null) {
                            if (attendanceFinal.containsKey('$formateddt')) {
                              sArr = attendanceFinal['$formateddt'];
                              _punchin = sArr[0]['in'];
                              _punchout = sArr[sArr.length - 1]['out'];
                            } else {
                              sArr = [];
                            }
                          }

                          return GestureDetector(
                            onTap: () async {
                              print("Ontapped");
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('selectedDate', formateddt);
                              prefs.setString('selectedDay', formatedday);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: MapPage(selectedDateArr: sArr),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 40, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                color: todayBg == 0
                                    ? Color(0xff0083fd)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 15.0,
                              ),
                              height: 100,
                              //  color: Color(0xff017EFD),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/calendar_grey.png"),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            formateddt,
                                            style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: todayBg == 0
                                                  ? Colors.white
                                                  : Colors.grey.withOpacity(.8),
                                            )),
                                          ),
                                        ),
                                        Text(
                                          formatedday.toUpperCase(),
                                          style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: todayBg == 0
                                                ? Colors.white
                                                : Colors.grey.withOpacity(.8),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Punch in',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: todayBg == 0
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.8),
                                                  //Color(0xffD1D3D4),
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              _punchin,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: todayBg == 0
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.8),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          height: 40,
                                          width: 1,
                                          color: todayBg == 0
                                              ? Colors.white.withOpacity(.4)
                                              : Colors.grey.withOpacity(.4),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Punch out',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: todayBg == 0
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.8),
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              _punchout,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: todayBg == 0
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(.8),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    //     ListView(

                    //   children: <Widget>[
                    //     Container(
                    //       padding: EdgeInsets.fromLTRB(20, 0, 40, 0),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(color: Colors.white),
                    //         borderRadius: BorderRadius.circular(20),
                    //         color: Color(0xffffffff),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Color(0xffa3b1c6), // darker color
                    //           ),
                    //           BoxShadow(
                    //             color: Color(0xffe0e5ec), // background color
                    //             spreadRadius: -12.0,
                    //             blurRadius: 12.0,
                    //           ),
                    //         ],
                    //       ),
                    //       margin: EdgeInsets.only(
                    //         bottom: 15.0,
                    //       ),
                    //       height: 100,
                    //       //  color: Color(0xff017EFD),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Container(
                    //             height: 60,
                    //             width: 80,
                    //             decoration: BoxDecoration(
                    //               image: DecorationImage(
                    //                 image: AssetImage(
                    //                     "assets/images/calendar_grey.png"),
                    //               ),
                    //             ),
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Container(
                    //                   padding: EdgeInsets.only(top: 5),
                    //                   child: Text(
                    //                     '${attendance[index][0]['dt']}',
                    //                     style: GoogleFonts.montserrat(
                    //                         textStyle: TextStyle(
                    //                       fontSize: 22,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: Color(0xffD1D3D4),
                    //                     )),
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   '${attendance[index][0]['day']}',
                    //                   style: GoogleFonts.montserrat(
                    //                       textStyle: TextStyle(
                    //                     fontSize: 14,
                    //                     fontWeight: FontWeight.w600,
                    //                     color: Color(0xffD1D3D4),
                    //                   )),
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //           Container(
                    //             child: Row(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Column(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Text(
                    //                       'Punch in',
                    //                       style: GoogleFonts.montserrat(
                    //                         textStyle: TextStyle(
                    //                           color: Color(0xffD1D3D4),
                    //                           fontWeight: FontWeight.w300,
                    //                           fontSize: 16,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     SizedBox(
                    //                       height: 6,
                    //                     ),
                    //                     Text(
                    //                       '${attendance[index][0]['in']}',
                    //                       style: GoogleFonts.montserrat(
                    //                         textStyle: TextStyle(
                    //                           color: Color(0xffD1D3D4),
                    //                           fontWeight: FontWeight.w600,
                    //                           fontSize: 16,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 Container(
                    //                   margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    //                   height: 40,
                    //                   width: 1,
                    //                   color: Color(0xffD1D3D4),
                    //                 ),
                    //                 Column(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Text(
                    //                       'Punch out',
                    //                       style: GoogleFonts.montserrat(
                    //                         textStyle: TextStyle(
                    //                           color: Color(0xffD1D3D4),
                    //                           fontWeight: FontWeight.w300,
                    //                           fontSize: 16,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     SizedBox(
                    //                       height: 6,
                    //                     ),
                    //                     Text(
                    //                       '${attendance[index][0]['out']}',
                    //                       style: GoogleFonts.montserrat(
                    //                         textStyle: TextStyle(
                    //                           color: Color(0xffD1D3D4),
                    //                           fontWeight: FontWeight.w600,
                    //                           fontSize: 16,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // )
                  );
                }),
              ),
            ],
          )),
    );
  }
}
