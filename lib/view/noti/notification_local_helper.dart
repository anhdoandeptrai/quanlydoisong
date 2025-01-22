// import 'dart:io';
// import 'dart:math';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:get/get.dart';

// class NotificationHelper {
//   static final NotificationHelper _instance = NotificationHelper._internal();
//   factory NotificationHelper() => _instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationHelper._internal();

//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher_noti');

//     final DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//       notificationCategories: [
//         DarwinNotificationCategory(
//           'demoCategory',
//           actions: <DarwinNotificationAction>[
//             DarwinNotificationAction.plain('id_1', 'Action 1'),
//             DarwinNotificationAction.plain(
//               'id_2',
//               'Action 2',
//               options: <DarwinNotificationActionOption>{
//                 DarwinNotificationActionOption.destructive,
//               },
//             ),
//             DarwinNotificationAction.plain(
//               'id_3',
//               'Action 3',
//               options: <DarwinNotificationActionOption>{
//                 DarwinNotificationActionOption.foreground,
//               },
//             ),
//           ],
//           options: <DarwinNotificationCategoryOption>{
//             DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
//           },
//         ),
//       ],
//     );

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: selectNotification,
//     );

//     // Yêu cầu quyền thông báo trên iOS
//     if (Platform.isIOS) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     }
//     if (Platform.isAndroid) {
//       FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );
//     }

//     FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     // App is Forground this method  work
//     FirebaseMessaging.onMessage.listen((message) {
//       print("FirebaseMessaging.onMessage.listen");
//       if (message.notification != null) {
//         if (Platform.isAndroid) {
//           // Local Notification Code to Display Alert
//           // NotificationHelper.displayNotification(message);
//           showNotification(
//             id: Random().nextInt(100),
//             title: message.notification!.title ?? "",
//             body: message.notification!.body ?? "",
//             payload: message.data['payload'] ?? "",
//           );
//         } else {
//           // NotificationHelper.displayNotification(message);
//         }
//       }
//       if (message.data.isNotEmpty) {
//         LogHelper.d("Data: ${message.data}");
//         if (message.data['payload'] == "cancelBooking") {
//           Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//           Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: true);
//           Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//         }
//         if (message.data['payload'] == "receiveBooking") {
//           Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//           Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: true);
//           Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//         }
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print("FirebaseMessaging.onMessageOpenedApp.listen");
//       if (message.notification != null) {
//         print(message.notification!.title);
//         print(message.notification!.body);
//         print(message.data);
//       }
//       if (message.data.isNotEmpty) {
//         LogHelper.d("Data: ${message.data}");
//         if (message.data['payload'] == "cancelBooking") {
//           Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//           Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: true);
//           Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//         }
//         if (message.data['payload'] == "receiveBooking") {
//           Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//           Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: false);
//           Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//         }
//       }
//     });
//   }

//   Future<void> showNotification(
//       {required int id,
//       required String title,
//       required String body,
//       String payload = ""}) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//             'your_channel_id', // id của kênh thông báo
//             'your_channel_name', // tên kênh thông báo
//             channelDescription:
//                 'your_channel_description', // mô tả kênh thông báo
//             importance: Importance.max,
//             priority: Priority.high,
//             showWhen: true,
//             color: Colors.transparent,
//             icon: '@mipmap/ic_launcher_noti'

//             // colorized: false,
//             );

//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//       categoryIdentifier: 'demoCategory',
//     );

//     final NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }

//   static Future selectNotification(
//       NotificationResponse notificationResponse) async {
//     // Xử lý khi người dùng nhấn vào thông báo
//     notificationResponse.payload;
//     if (notificationResponse.payload != "") {
//       if (notificationResponse.payload == "cancelBooking") {
//         Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//         Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: true);
//         Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//       }
//       if (notificationResponse.payload == "receiveBooking") {
//         Get.put(BottomBarViewModel()).controllerBar.value.index = 1;
//         Get.put(HistoryTripViewModel()).togglePage(isRequiredFalse: false);
//         Get.put(HistoryTripViewModel()).getHistoryTripOrder();
//       }
//     }
//   }

//   static Future onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     // Xử lý thông báo nhận được khi ứng dụng đang chạy (foreground)
//     // Ví dụ: hiển thị một hộp thoại hoặc thông báo trong ứng dụng
//     print('Received notification: $title - $body');
//     // Get.snackbar(
//     //   "Thông Báo",
//     //   "TEST",
//     //   snackPosition: SnackPosition.TOP,
//     // );
//   }
// }
