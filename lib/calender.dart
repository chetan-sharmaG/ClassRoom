// import 'dart:collection';
// import 'dart:convert';
// import 'dart:math';
//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:html/parser.dart' as htmlParser;
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:omni_datetime_picker/omni_datetime_picker.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:untitled/models/getEvents.dart';
//
// import 'HomePage.dart';
//
// class ShowCalender extends StatefulWidget {
//   const ShowCalender({super.key});
//
//   @override
//   State<ShowCalender> createState() => _ShowCalenderState();
// }
//
// class _ShowCalenderState extends State<ShowCalender> {
//   late DateTime _focusedDay;
//   late DateTime _firstDay;
//   late DateTime _lastDay;
//   late DateTime _selectedDay;
//   late CalendarFormat _calendarFormat;
//   late Map<DateTime, List<Event>> _events;
//   late final String API_KEY;
//   DocumentSnapshot? snapshot = HomePage.getSnapshot();
//
//   bool isAdmin = false;
//
//   int getHashCode(DateTime key) {
//     return key.day * 1000000 + key.month * 10000 + key.year;
//   }
//
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//     getRole();
//     API_KEY = 'AIzaSyCxSXIoBB-5NDirm7U2QTfP-hFoeh73Eqk';
//     _events = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
//     _focusedDay = DateTime.now();
//     _firstDay = DateTime.now().subtract(const Duration(days: 1000));
//     _lastDay = DateTime.now().add(const Duration(days: 1000));
//     _selectedDay = DateTime.now();
//     _calendarFormat = CalendarFormat.month;
//     _loadFirestoreEvents();
//     Future.delayed(const Duration(seconds: 3), () {
//       setState(() {
//         _isLoading = false;
//       });
//     });
//   }
//
//   setReminder(DateTime dateTime, String title) async {
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//             id: Random().nextInt(100),
//             channelKey: 'scheduled_notification',
//             title: 'Event Reminder',
//             body: "It's a Reminder for $title event",
//             notificationLayout: NotificationLayout.Default,
//             displayOnBackground: true,
//             displayOnForeground: true),
//         schedule: NotificationCalendar.fromDate(date: dateTime));
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           child: const Text(
//             'Reminder was set Successfully',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }
//
//   _addEvent(DateTime day, Event event) async {
//     if (_events[day] == null) {
//       _events[day] = [];
//     }
//     String? groups =
//         '${snapshot!.get('currentSemester')} ${snapshot!.get('course')} ${snapshot!.get('currentSection')}';
//     if (event.group == groups || event.group?.toLowerCase() == 'all') {
//       _events[day]!.add(event);
//     } else {
//       _events[day] = [];
//     }
//   }
//
//   _addEventForHolidays(DateTime day, Event event) {
//     if (_events[day] == null) {
//       _events[day] = [];
//     }
//     if (event.description ==
//         "Observance\nTo hide observances, go to Google Calendar Settings > Holidays in India") {
//       // Create a new event with the same properties but an empty description
//       final modifiedEvent = Event(
//         title: event.title,
//         date: event.date,
//         id: event.id,
//         description:
//             '', // Empty description for holidays with specific description
//       );
//
//       _events[day]!.add(modifiedEvent);
//     } else {
//       _events[day]!.add(event);
//     }
//   }
//
//   _loadFirestoreEvents() async {
//     _events.clear();
//     final snap = await FirebaseFirestore.instance
//         .collection('events')
//         .withConverter(
//             fromFirestore: Event.fromFireStore,
//             toFirestore: (event, options) => event.toFireStore())
//         .get();
//     for (var doc in snap.docs) {
//       final event = doc.data();
//       final day =
//           DateTime.utc(event.date.year, event.date.month, event.date.day);
//       _addEvent(day, event);
//     }
//     // if (_events[day] == null) {
//     //   _events[day] = [];
//     // }
//     // _events[day]!.add(event);
//     final googleHolidayApiResponse = await http.get(Uri.parse(
//         'https://www.googleapis.com/calendar/v3/calendars/en.indian%23holiday%40group.v.calendar.google.com/events?key=$API_KEY'));
//     final googleHolidayEvents =
//         json.decode(googleHolidayApiResponse.body)['items'];
//
//     for (var event in googleHolidayEvents) {
//       final holidayEvent = Event.fromGoogleHolidayApi(event);
//       final day = DateTime.utc(holidayEvent.date.year, holidayEvent.date.month,
//           holidayEvent.date.day);
//       if (_events[day]?.contains(holidayEvent) != true) {
//         _addEventForHolidays(day, holidayEvent);
//       }
//     }
//     //Navigator.of(context).pop();
//   }
//
//   List<Event> _getEventsForTheDay(DateTime day) {
//     final List<Event> events = _events[day] ?? [];
//     return events;
//   }
//
//   String removeSpace(String title) {
//     String festival = title;
//     if (festival.contains(" ")) {
//       return festival.replaceAll(" ", "-");
//     } else {
//       return festival;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Calender/Events',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         toolbarHeight: 70,
//         backgroundColor: const Color(0xff2c2e3a),
//       ),
//       backgroundColor: const Color(0xffead8d8),
//       body: Container(
//         decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
//         child: Align(
//           //alignment: Alignment.center,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _isLoading
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       //crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                           LoadingAnimationWidget.dotsTriangle(
//                             color: Colors.yellow,
//                             size: 50,
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               'Loading up your Calender',
//                               style: TextStyle(
//                                   fontSize: 18, color: Colors.deepOrangeAccent),
//                             ),
//                           )
//                         ])
//                   : TableCalendar(
//                       // rowHeight: 43,
//                       eventLoader: _getEventsForTheDay,
//                       calendarFormat: _calendarFormat,
//                       onFormatChanged: (format) {
//                         setState(() {
//                           _calendarFormat = format;
//                         });
//                       },
//                       availableGestures: AvailableGestures.all,
//                       headerStyle: const HeaderStyle(
//                         formatButtonTextStyle: TextStyle(color: Colors.yellow),
//                         formatButtonVisible: false,
//                         titleCentered: true,
//                         leftChevronIcon: Icon(
//                           Icons.keyboard_arrow_left,
//                           size: 20,
//                           color: Colors.white,
//                         ),
//                         rightChevronIcon: Icon(
//                           Icons.keyboard_arrow_right,
//                           size: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                       firstDay: _firstDay,
//                       focusedDay: _focusedDay,
//                       lastDay: _lastDay,
//                       startingDayOfWeek: StartingDayOfWeek.monday,
//                       onPageChanged: (focusedDay) {
//                         setState(() {
//                           _focusedDay = focusedDay;
//                         });
//                       },
//                       selectedDayPredicate: (day) =>
//                           isSameDay(day, _selectedDay),
//                       onDaySelected: (selectedDay, focusedDay) {
//                         setState(() {
//                           _selectedDay = selectedDay;
//                           _focusedDay = focusedDay;
//                         });
//                       },
//                       rowHeight: 70,
//                       daysOfWeekHeight: 20,
//                       daysOfWeekStyle: const DaysOfWeekStyle(
//                         weekdayStyle: TextStyle(
//                           //fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                           color: Color(0xffe6e4ae),
//                           height: 1.3333333333333333,
//                         ),
//                         weekendStyle: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                           color: Color(0xffe6e4ae),
//                           height: 1.3333333333333333,
//                         ),
//                       ),
//                       calendarStyle: const CalendarStyle(
//                         markersAutoAligned: false,
//                         outsideDaysVisible: false,
//                         markersMaxCount: 20,
//                         markerDecoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.yellow,
//                         ),
//                         weekNumberTextStyle: TextStyle(color: Colors.white),
//                         weekendTextStyle: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                           color: Colors.white70,
//                           height: 1.3333333333333333,
//                         ),
//                         defaultTextStyle: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                           color: Colors.cyan,
//                           height: 1.3333333333333333,
//                         ),
//                         selectedDecoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.red,
//                         ),
//                       ),
//                       calendarBuilders: CalendarBuilders(
//                         headerTitleBuilder: (context, day) {
//                           final text = DateFormat.yMMM().format(day);
//                           return Container(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               text.toString(),
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.lime),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//               const SizedBox(
//                 height: 30,
//               ),
//               _isLoading
//                   ? const SizedBox.shrink()
//                   : Expanded(
//                       child: ListView.builder(
//                         itemCount: _getEventsForTheDay(_selectedDay).length,
//                         itemBuilder: (context, index) {
//                           final event =
//                               _getEventsForTheDay(_selectedDay)[index];
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 15.0,
//                                   vertical: 4.0,
//                                 ),
//                                 child: Text(
//                                   event.group == null ? 'Festivals' : 'Events',
//                                   style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.cyanAccent),
//                                 ),
//                               ),
//                               Container(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 12.0,
//                                   vertical: 4.0,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.limeAccent),
//                                   borderRadius: BorderRadius.circular(12.0),
//                                 ),
//                                 child: ListTile(
//                                   onTap: () async {
//                                     if (event.group == null) {
//                                       var festival = removeSpace(event.title);
//                                       var dataa =
//                                           await fetchAndParseHtml(festival);
//                                       showDialog(
//                                         context: context,
//                                         builder: (context) {
//                                           return Dialog(
//                                             backgroundColor: Colors.black45,
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(5)),
//                                             child: SingleChildScrollView(
//                                               //padding: EdgeInsets.symmetric(horizontal: 10),
//                                               //height: MediaQuery.of(context).size.height*0.6,
//                                               child: Column(children: [
//                                                 Html(
//                                                   style: {
//                                                     "h1": Style(
//                                                       color: Colors.red,
//                                                     ),
//                                                     "h2": Style(
//                                                         color: Colors.blue),
//                                                     "p": Style(
//                                                         color: Colors.white70),
//                                                     "span": Style(
//                                                         color: Colors.white70),
//                                                     "li": Style(
//                                                         color: Colors.white70)
//                                                   },
//                                                   data: dataa,
//                                                   shrinkWrap: true,
//                                                 ),
//                                                 dataa == 'Error'
//                                                     ? const Text(
//                                                         "Couldn't retreive data from server",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.white))
//                                                     : const Text(
//                                                         "Source:Redbus.in",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.white)),
//                                               ]),
//                                             ),
//                                           );
//                                         },
//                                       );
//                                     }
//                                   },
//                                   title: Padding(
//                                     padding: const EdgeInsets.only(bottom: 5.0),
//                                     child: Text(
//                                       event.title,
//                                       style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w400,
//                                           color: Colors.white),
//                                     ),
//                                   ),
//                                   subtitle: Stack(children: [
//                                     Align(
//                                       alignment: Alignment.bottomLeft,
//                                       child: SizedBox(
//                                         width: (MediaQuery.of(context)
//                                                 .size
//                                                 .width) /
//                                             2,
//                                         child: Align(
//                                           alignment: Alignment.bottomLeft,
//                                           child: Text(event.description ?? '',
//                                               maxLines: 6,
//                                               style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontStyle: FontStyle.normal,
//                                                   fontWeight: FontWeight.w100,
//                                                   color: Colors.redAccent)),
//                                         ),
//                                       ),
//                                     ),
//                                     event.group != null
//                                         ? Align(
//                                             alignment: Alignment.topRight,
//                                             child: TextButton(
//                                                 style: TextButton.styleFrom(
//                                                     padding: EdgeInsets.zero,
//                                                     minimumSize:
//                                                         const Size(40, 20),
//                                                     tapTargetSize:
//                                                         MaterialTapTargetSize
//                                                             .shrinkWrap,
//                                                     alignment:
//                                                         Alignment.centerLeft),
//                                                 onPressed: () async {
//                                                   DateTime? dateTime =
//                                                       await showOmniDateTimePicker(
//                                                     context: context,
//                                                     initialDate: DateTime.now(),
//                                                     firstDate: DateTime.now(),
//                                                     lastDate: event.date,
//                                                     is24HourMode: false,
//                                                     isShowSeconds: false,
//                                                     minutesInterval: 1,
//                                                     secondsInterval: 1,
//                                                     borderRadius:
//                                                         const BorderRadius.all(
//                                                             Radius.circular(
//                                                                 16)),
//                                                     constraints:
//                                                         const BoxConstraints(
//                                                       maxWidth: 350,
//                                                       maxHeight: 650,
//                                                     ),
//                                                     transitionBuilder: (context,
//                                                         anim1, anim2, child) {
//                                                       return FadeTransition(
//                                                         opacity: anim1.drive(
//                                                           Tween(
//                                                             begin: 0,
//                                                             end: 1,
//                                                           ),
//                                                         ),
//                                                         child: child,
//                                                       );
//                                                     },
//                                                     transitionDuration:
//                                                         const Duration(
//                                                             milliseconds: 200),
//                                                     barrierDismissible: true,
//                                                   );
//                                                   if (dateTime != null) {
//                                                     setReminder(
//                                                         dateTime, event.title);
//                                                   }
//                                                 },
//                                                 child: const Text(
//                                                   'Remind Me!',
//                                                   style: TextStyle(
//                                                       color: Colors.blue),
//                                                 )),
//                                           )
//                                         : const SizedBox.shrink()
//                                   ]),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton:
//       isAdmin ? _buildFloatingActionButton(context) : null,
//     );
//   }
//   _buildFloatingActionButton(BuildContext context) {
//     return FloatingActionButton(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(40),
//       ),
//       onPressed: () {
//         showGeneralDialog(
//           context: context,
//           barrierDismissible: true,
//           barrierLabel:
//           MaterialLocalizations.of(context).modalBarrierDismissLabel,
//           barrierColor: Colors.black45,
//           transitionDuration: const Duration(milliseconds: 200),
//           pageBuilder: (BuildContext buildContext, Animation animation,
//               Animation secondaryAnimation) {
//             return Scaffold( // Wrap the content in a Scaffold
//               backgroundColor: Colors.transparent,
//               body: Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width - 10,
//                   height: MediaQuery.of(context).size.height - 80,
//                   color: Colors.white,
//                   child: Stack(
//                     children: [
//                       SizedBox(
//                         height: 60,
//                         width:MediaQuery.of(context).size.width - 10,
//                         child: DrawerHeader(
//                           decoration:
//                           const BoxDecoration(color: Color(0xff2c2e3a)),
//                           child:SizedBox.shrink()
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 13.0,left: 10),
//                         child: Row(
//                           // crossAxisAlignment: CrossAxisAlignment.start,
//                           // mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             GestureDetector(
//                               onTap: (){
//                                 Navigator.pop(context);
//                               },
//                               child: Icon(
//                                 Icons.arrow_back,
//                                 color: Colors.red,
//                                 size: 30,
//                               ),
//                             ),SizedBox(width: 10,),
//                             Text(
//                               'Add Event',
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 height: 1.33,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//       child: const Icon(Icons.add),
//     );
//   }
//
//
//   Future<void> getRole() async {
//     String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUserId)
//         .get();
//     isAdmin = snapshot.exists && snapshot.get('role') == 'admin';
//   }
//   Future<String> fetchAndParseHtml(String event) async {
//     try {
//       String url = 'https://www.redbus.in/festivals/$event';
//       // Make an HTTP request to get the HTML content
//       http.Response response = await http.get(Uri.parse(url));
//
//       // Check if the request was successful (status code 200)
//       if (response.statusCode == 200) {
//         // Parse the HTML content
//         var document = htmlParser.parse(response.body);
//
//         // Find the div with class 'texting'
//         var divElement = document.querySelector('article.D103_main');
//
//         if (divElement != null) {
//           // Print the entire div with its tags
//           return divElement.outerHtml;
//         } else {
//           return 'Couldnt Retrive Error';
//         }
//       } else {
//         return 'Error';
//       }
//     } catch (e) {
//       return 'Error';
//     }
//   }
// }
import 'dart:async';
import 'dart:collection';
import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/models/getEvents.dart';
import 'package:untitled/utils/local_notification.dart';

import 'HomePage.dart';

class ShowCalender extends StatefulWidget {
  //const ShowCalender({super.key});
  final DateTime? date;

  ShowCalender({super.key, this.date});

  @override
  State<ShowCalender> createState() => _ShowCalenderState();
}

class _ShowCalenderState extends State<ShowCalender> {
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<Event>> _events;
  late final String API_KEY;
  DocumentSnapshot? snapshot = HomePage.getSnapshot();
  bool isAdmin = false;

   String text='';

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  late StreamController<List<Event>> _eventsController; // Added

  @override
  void initState() {
    super.initState();
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    getRole();
    API_KEY = 'AIzaSyCxSXIoBB-5NDirm7U2QTfP-hFoeh73Eqk';
    _events = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
    _focusedDay = widget.date ?? DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    print(widget.date);
    _selectedDay = widget.date ?? DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _eventsController = StreamController<List<Event>>(); // Added
    _loadFirestoreEvents();
  }

  @override
  void dispose() {
    _eventsController.close(); // Added
    super.dispose();
  }

  setReminder(DateTime dateTime, String title) async {
    LocalNotification.scheduleNotification(title: "Hello",body: "ad",id: 123,scheduledNotificationDateTime: dateTime);
    // await AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: Random().nextInt(100),
    //         channelKey: 'scheduled_notification',
    //         title: 'Event Reminder',
    //         body: "It's a Reminder for $title event",
    //         notificationLayout: NotificationLayout.Default,
    //         displayOnBackground: true,
    //         displayOnForeground: true),
    //     schedule: NotificationCalendar.fromDate(date: dateTime));

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: const Text(
            'Reminder was set Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Future<List<Event>> _addEvent(DateTime day, Event event) async {
    List<Event> eventsList = [];
    if (_events[day] == null) {
      _events[day] = [];
    }
    String? groups =
        '${snapshot!.get('currentSemester')} ${snapshot!.get('course')} ${snapshot!.get('currentSection')}';
    if (event.group == groups || event.group?.toLowerCase() == 'all') {
      eventsList.add(event);
      _events[day]!.add(event);
      return eventsList;
    } else {
      _events[day] = [];
      return eventsList;
    }
  }

  List<Event> _addEventForHolidays(DateTime day, Event event) {
    List<Event> holidayEventsList = [];
    if (_events[day] == null) {
      _events[day] = [];
    }
    if (event.description ==
        "Observance\nTo hide observances, go to Google Calendar Settings > Holidays in India") {
      // Create a new event with the same properties but an empty description
      final modifiedEvent = Event(
        title: event.title,
        date: event.date,
        id: event.id,
        description:
            '', // Empty description for holidays with specific description
      );
      holidayEventsList.add(modifiedEvent);
      _events[day]!.add(modifiedEvent);
      return holidayEventsList;
    } else {
      _events[day]!.add(event);
      holidayEventsList.add(event);
      return holidayEventsList;
    }
  }

  _loadFirestoreEvents() async {
    _events.clear();

    List<Event> a1 = [];
    List<Event> a2 = [];
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .withConverter(
            fromFirestore: Event.fromFireStore,
            toFirestore: (event, options) => event.toFireStore())
        .get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);

      a1 = await _addEvent(day, event);
    }

    final googleHolidayApiResponse = await http.get(Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/en.indian%23holiday%40group.v.calendar.google.com/events?key=$API_KEY'));
    final googleHolidayEvents =
        json.decode(googleHolidayApiResponse.body)['items'];

    for (var event in googleHolidayEvents) {
      final holidayEvent = Event.fromGoogleHolidayApi(event);
      final day = DateTime.utc(holidayEvent.date.year, holidayEvent.date.month,
          holidayEvent.date.day);
      if (_events[day]?.contains(holidayEvent) != true) {
        a2 = await _addEventForHolidays(day, holidayEvent);
      }
    }
    _eventsController.add(a1 + a2);
    // Added
    //Navigator.of(context).pop();
  }

  List<Event> _getEventsForTheDay(DateTime day) {
    final List<Event> events = _events[day] ?? [];
    return events;
  }

  String removeSpace(String title) {
    String festival = title;
    if (festival.contains(" ")) {
      return festival.replaceAll(" ", "-");
    } else {
      return festival;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton:
          isAdmin ? _buildFloatingActionButton(context) : null,
      appBar: AppBar(
        title: const Text(
          'Calender/Events',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xff2c2e3a),
      ),
      backgroundColor: const Color(0xffead8d8),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
        child: StreamBuilder<List<Event>>(
          // Changed
          stream: _eventsController.stream, // Changed
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.dotsTriangle(
                      color: Colors.yellow,
                      size: 50,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Loading up your Calender',
                        style: TextStyle(
                            fontSize: 18, color: Colors.deepOrangeAccent),
                      ),
                    )
                  ]); // You can define your loading widget
            } else if (snapshot.hasError) {
              return Center(
                child: Text('error'),
              ); // You can define your error widget
            } else {
              return calendar(); // You can define your content widget
            }
          },
        ),
      ),
    );
  }

  SingleChildScrollView calendar() {
    return SingleChildScrollView(
      child: ListView(
        shrinkWrap: true,
        children: [
          TableCalendar(
            // rowHeight: 43,
            eventLoader: _getEventsForTheDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            availableGestures: AvailableGestures.all,
            headerStyle: const HeaderStyle(
              formatButtonTextStyle: TextStyle(color: Colors.yellow),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.keyboard_arrow_left,
                size: 20,
                color: Colors.white,
              ),
              rightChevronIcon: Icon(
                Icons.keyboard_arrow_right,
                size: 20,
                color: Colors.white,
              ),
            ),
            firstDay: _firstDay,
            focusedDay: _focusedDay,
            lastDay: _lastDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            rowHeight: 70,
            daysOfWeekHeight: 20,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                //fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xffe6e4ae),
                height: 1.3333333333333333,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xffe6e4ae),
                height: 1.3333333333333333,
              ),
            ),
            calendarStyle: const CalendarStyle(
              markersAutoAligned: false,
              outsideDaysVisible: false,
              markersMaxCount: 20,
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow,
              ),
              weekNumberTextStyle: TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white70,
                height: 1.3333333333333333,
              ),
              defaultTextStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.cyan,
                height: 1.3333333333333333,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                final text = DateFormat.yMMM().format(day);
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.lime),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _getEventsForTheDay(_selectedDay).length,
            itemBuilder: (context, index) {
              final event = _getEventsForTheDay(_selectedDay)[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      event.group == null ? 'Festivals' : 'Events',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyanAccent),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.limeAccent),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () async {
                        if (event.group == null) {
                          var festival = removeSpace(event.title);
                          var dataa = await fetchAndParseHtml(festival);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.black45,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: SingleChildScrollView(
                                  //padding: EdgeInsets.symmetric(horizontal: 10),
                                  //height: MediaQuery.of(context).size.height*0.6,
                                  child: Column(children: [
                                    Html(
                                      style: {
                                        "h1": Style(
                                          color: Colors.red,
                                        ),
                                        "h2": Style(color: Colors.blue),
                                        "p": Style(color: Colors.white70),
                                        "span": Style(color: Colors.white70),
                                        "li": Style(color: Colors.white70)
                                      },
                                      data: dataa,
                                      shrinkWrap: true,
                                    ),
                                    dataa == 'Error'
                                        ? const Text(
                                            "Couldn't retreive data from server",
                                            style:
                                                TextStyle(color: Colors.white))
                                        : const Text("Source:Redbus.in",
                                            style:
                                                TextStyle(color: Colors.white)),
                                  ]),
                                ),
                              );
                            },
                          );
                        }
                      },
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          event.title,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      subtitle: Stack(children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width) / 2,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(event.description ?? '',
                                  maxLines: 6,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.redAccent)),
                            ),
                          ),
                        ),
                        event.group != null
                            ? Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(40, 20),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        alignment: Alignment.centerLeft),
                                    onPressed: () async {
                                      DateTime? dateTime =
                                          await showOmniDateTimePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: event.date,
                                        is24HourMode: false,
                                        isShowSeconds: false,
                                        minutesInterval: 1,
                                        secondsInterval: 1,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16)),
                                        constraints: const BoxConstraints(
                                          maxWidth: 350,
                                          maxHeight: 650,
                                        ),
                                        transitionBuilder:
                                            (context, anim1, anim2, child) {
                                          return FadeTransition(
                                            opacity: anim1.drive(
                                              Tween(
                                                begin: 0,
                                                end: 1,
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 200),
                                        barrierDismissible: true,
                                      );
                                      if (dateTime != null) {
                                        setReminder(dateTime, event.title);
                                      }
                                    },
                                    child: const Text(
                                      'Remind Me!',
                                      style: TextStyle(color: Colors.blue),
                                    )),
                              )
                            : const SizedBox.shrink()
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              // Wrap the content in a Scaffold
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.blueGrey,
                        Colors.black,
                        Color(0xff2c2e3a)
                      ])),
                  width: MediaQuery.of(context).size.width - 25,
                  height: MediaQuery.of(context).size.height - 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width - 10,
                            child: DrawerHeader(
                                decoration: const BoxDecoration(
                                    color: Color(0xff2c2e3a)),
                                child: SizedBox.shrink()),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0, left: 10),
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Add Event',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    height: 1.33,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextField(
                            style: TextStyle(color: Colors.lime),
                            maxLines: 1,
                            decoration: InputDecoration(
                                labelText: 'Event Name',
                                border: UnderlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.white)),
                          ),
                        ),

                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0,top: 20),
                          child: TextField(
                            style: TextStyle(color: Colors.lime),
                            maxLines: 2,
                            decoration: InputDecoration(
                                labelText: 'Event Description',
                                border: UnderlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0,top: 20),
                        child: TextButton(onPressed: () async {
                          DateTime? dateTime =
                              await showOmniDateTimePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 1,
                            secondsInterval: 1,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(16)),
                            constraints: const BoxConstraints(
                              maxWidth: 350,
                              maxHeight: 650,
                            ),
                            transitionBuilder:
                                (context, anim1, anim2, child) {
                              return FadeTransition(
                                opacity: anim1.drive(
                                  Tween(
                                    begin: 0,
                                    end: 1,
                                  ),
                                ),
                                child: child,
                              );
                            },
                            transitionDuration:
                            const Duration(milliseconds: 200),
                            barrierDismissible: true,
                          );
                          if(dateTime!=null){
                            setState(() {
                              dateTimeForEvent=dateTime;
                              dateTimeVis=true;
                              print(dateTimeVis);
                              text = DateFormat.yMMM().format(dateTime);
                              print(text);
                            });
                          }
                        }, child: Text('dasd',style: TextStyle(
                          fontSize: 20
                        ),)),
                      ),
                      Visibility(
                        visible: dateTimeVis,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: Text(text,style: TextStyle(
                            color: Colors.white
                          ),)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );  
      },
      child: const Icon(Icons.add),
    );
  }
  late DateTime dateTimeForEvent;
  bool dateTimeVis = false;
  Future<void> getRole() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .get();
    isAdmin = snapshot.exists && snapshot.get('role') == 'admin';
  }

  Future<String> fetchAndParseHtml(String event) async {
    try {
      String url = 'https://www.redbus.in/festivals/$event';
      // Make an HTTP request to get the HTML content
      http.Response response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the HTML content
        var document = htmlParser.parse(response.body);

        // Find the div with class 'texting'
        var divElement = document.querySelector('article.D103_main');

        if (divElement != null) {
          // Print the entire div with its tags
          return divElement.outerHtml;
        } else {
          return 'Couldnt Retrive Error';
        }
      } else {
        return 'Error';
      }
    } catch (e) {
      return 'Error';
    }
  }
}
