import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:untitled/Erp.dart';
import 'package:untitled/HomePage.dart';
import 'package:untitled/calender.dart';
import 'package:untitled/course_selection.dart';
import 'package:untitled/firebase_options.dart';
import 'package:untitled/login.dart';
import 'package:untitled/register.dart';
import 'package:untitled/studentDirectory.dart';
import 'package:untitled/utils/constant.dart';
import 'package:untitled/utils/local_notification.dart';
import 'package:untitled/view_notes.dart';

import 'auth_page.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// used to pass messages from event handler to the UI
 final _messageStreamController = BehaviorSubject<RemoteMessage>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(message.notification!.title);
  }

}
void _handleMessage(RemoteMessage message) {
  if (message.data[Constant.route] == Constant.routeName) {
    navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => const StudentDirectory(),
        ));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LocalNotification.initialize();
  tz.initializeTimeZones();

  // Optionally, set a default local location
  tz.setLocalLocation(tz.getLocation(Constant.IST_LOCATION));
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  // If the message also contains a data property with a "type" of "chat",
  // navigate to a chat screen
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      LocalNotification.display(message);
    }
      _messageStreamController.sink.add(message);
  });
  // FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //   print("on message opened app"+message.toString());
  // });
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);


  // To handle when app is open in
  // user divide and heshe is using it

  // AwesomeNotifications().initialize(
  //   //'resource://drawable/res_notification_app_icon',
  //     null,
  //     [
  //       NotificationChannel(
  //         channelGroupKey: 'reminder',
  //         importance: NotificationImportance.High,
  //         channelKey: 'scheduled_notification',
  //         channelName: 'Scheduled_notification',
  //         playSound: true,
  //
  //         channelDescription: 'Notification channel for basic notifications',
  //         defaultColor: const Color(0xFF9D50DD),
  //         ledColor: Colors.white,
  //       ),
  //     ],
  //     debug: true);
  ////////Crashlystic
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };

  ///


  await FirebaseMessaging.instance.subscribeToTopic(Constant.subscribeAll);
  // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  //   if (!isAllowed) {
  //     AwesomeNotifications().requestPermissionToSendNotifications();
  //   }});
  if (kDebugMode) {
    //print('Registration Token=$token');
  }

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   // await AwesomeNotifications().createNotification(
  //   //   content: NotificationContent(
  //   //       id: Random().nextInt(100),
  //   //       channelKey: 'scheduled_notification',
  //   //       title:message.notification?.title,
  //   //       body: message.notification?.body,
  //   //       payload: {'route':message.data['route']},
  //   //       hideLargeIconOnExpand: true,
  //   //       notificationLayout: NotificationLayout.Default,
  //   //       displayOnBackground: true,
  //   //       displayOnForeground: true),
  //   // );
  //
  //   if (kDebugMode) {
  //     print('Handling a foreground message: ${message.messageId}');
  //     print('Message data: ${message.data}');
  //     print('Message notification: ${message.notification?.title}');
  //     print('Message notification: ${message.notification?.body}');
  //   }
  //   _messageStreamController.sink.add(message);
  //
  // });
  // // AwesomeNotifications().setListeners(
  // //   onActionReceivedMethod: (ReceivedAction receivedAction)async{
  // //     NotificationController.onActionReceivedMethod(receivedAction);
  // //   },
  // // );
  //
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   print('---------------------------');
  //   String route = message.data['route'];
  //
  //   if(route=='calendar'){
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (_) => ShowCalender(),
  //     ));
  //   }
  //   if(route=='directory'){
  //     navigatorKey.currentState?.push(MaterialPageRoute(
  //       builder: (_) => const StudentDirectory(),
  //     ));
  //   }
  // });

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: Constant.fontFamily),
    initialRoute: 'auth_page',
    routes: {
      'auth_page': (context) => const AuthPage(),
      'login': (context) => const MyLogin(),
      'register': (context) => const MyRegister(),
      'homepage': (context) => const HomePage(),
      'notes_selection': (context) => const notesSelection(),
      'erp': (context) => const ErpView(),
      'ShowCalender': (context) =>  ShowCalender(),
      'getNotes': (context) => const ViewAndDownloadNotes(),
      //'profile':(context) => const UserProfile(),
      'directory': (context) => const StudentDirectory()
      //'SubjectSelection':(context) => SubjectSelection()
    },
  ));
}
