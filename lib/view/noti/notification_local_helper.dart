import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_helper.dart';

class FirebaseNotificationHelper {
  static final FirebaseNotificationHelper _instance =
      FirebaseNotificationHelper._internal();
  factory FirebaseNotificationHelper() => _instance;

  FirebaseNotificationHelper._internal();

  Future<void> initialize() async {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      print("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        NotificationHelper().showNotification(
          id: Random().nextInt(100),
          title: message.notification!.title ?? "",
          body: message.notification!.body ?? "",
          payload: message.data['payload'] ?? "",
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print(message.data);
      }
    });
  }
}
