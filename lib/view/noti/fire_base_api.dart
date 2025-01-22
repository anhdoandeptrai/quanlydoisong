// import 'package:firebase_messaging/firebase_messaging.dart';

// class FirebaseApi{
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> iniNotifications() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     final fCMToken = await _firebaseMessaging.getToken();

//     print('FCM Token: $fCMToken');
//   }
   
// } 