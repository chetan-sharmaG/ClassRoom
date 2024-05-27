import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled/calender.dart';

class LocalNotification{

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static void initialize(){
    InitializationSettings initializationSettings =
        const InitializationSettings(
          android: AndroidInitializationSettings("@drawable/ic_launcher"));
    _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if(details.input!=null){}
      },
      // onDidReceiveBackgroundNotificationResponse: (details) {
      //   print(details);
      // },
    );
  }

  static Future<void> scheduleNotification(
      {int id = 0,
        String? title,
        String? body,
        String? payLoad,
        required DateTime scheduledNotificationDateTime}) async {
    return _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
  static NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('Channel Id', 'Main Channel',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  static Future<void> display(RemoteMessage message) async {
    try{
      print(message.data['route']);
      final id =DateTime.now().millisecondsSinceEpoch ~/1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          message.notification!.android!.sound ?? "Channel Id",
          message.notification!.android!.sound ?? "Main Channel",
          groupKey: 'cr',
          color: const Color(0xff2c2e3a),
          importance: Importance.max,
          playSound: true,
          priority: Priority.max
        )
      );
      await _plugin.show(id, message.notification!.title, message.notification!.body,notificationDetails, payload: message.data['route']);
    }catch (e) {
      debugPrint(e.toString());
    }
  }
}