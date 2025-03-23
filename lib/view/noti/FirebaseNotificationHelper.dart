import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_helper.dart';

class FirebaseNotificationHelper {
  static final FirebaseNotificationHelper _instance =
      FirebaseNotificationHelper._internal();
  factory FirebaseNotificationHelper() => _instance;

  FirebaseNotificationHelper._internal();

  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationHelper().showNotification(
          id: Random().nextInt(100),
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? 'Bạn có thông báo mới',
          payload: message.data['scheduleId'] ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('scheduleId')) {
        final scheduleId = message.data['scheduleId'];
        _handleMessageClick(scheduleId);
      }
    });
  }

  void _handleMessageClick(String scheduleId) {
    print('User opened app from notification - scheduleId: $scheduleId');
    // Điều hướng tới màn hình chi tiết (tuỳ bạn tự build)
    // Example:
    // Navigator.pushNamed(context, '/scheduleDetail', arguments: scheduleId);
  }
}
