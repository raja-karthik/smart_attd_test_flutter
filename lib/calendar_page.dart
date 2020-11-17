import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

List<DateTime> presentDates = [
  DateTime(2020, 11, 3),
  DateTime(2020, 11, 4),
  DateTime(2020, 11, 6),
  DateTime(2020, 11, 9),
  DateTime(2020, 11, 10),
  DateTime(2020, 11, 11),
  DateTime(2020, 11, 13),
  DateTime(2020, 11, 16),
];

List<DateTime> earlyDates = [
  DateTime(2020, 11, 12),
];
List<DateTime> absentDates = [
  DateTime(2020, 11, 2),
  DateTime(2020, 11, 5),
];

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentDate = DateTime.now();
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

  var len = presentDates.length;
  var len2 = absentDates.length;
  var len3 = earlyDates.length;

  double cHeight;

  // Future<bool> _onBackPressed() {
  //   print("Back key pressed from calender page");
  // }

  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;
    for (int i = 0; i < len; i++) {
      _markedDateMap.add(
        presentDates[i],
        new Event(
          date: presentDates[i],
          title: 'Event 5',
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
          title: 'Event 5',
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
          title: 'Event 5',
          icon: _earlyIcon(
            earlyDates[i].day.toString(),
          ),
        ),
      );
    }
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
      // onCalendarChanged: (date) {
      //   print(date);
      //   setState(() {
      //     presentDates = presentDates2;
      //     absentDates = absentDates2;
      //   });
      // },
      minSelectedDate: DateTime(currentDate.year, currentDate.month - 12, 1),
      maxSelectedDate: DateTime(currentDate.year, currentDate.month + 1, 0),

      // headerTitleTouchable: true,
      todayButtonColor: Color(0xffffffff),

      todayBorderColor: Colors.blue,
      headerTitleTouchable: true,
      markedDatesMap: _markedDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      // daysHaveCircularBorder: true,
      onDayPressed: (DateTime date, List<Event> event) {
        print('On DAY PRESSED $date - EVENT $event');
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
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _calendarCarouselNoHeader,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    markerRepresent(Color(0xff00bbfb), "Present"),
                    markerRepresent(Colors.orangeAccent, "Leave"),
                    markerRepresent(Colors.redAccent, "Early"),
                  ],
                ),
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
            ),
          )
        ]);
  }
}
