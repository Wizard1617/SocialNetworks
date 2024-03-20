import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:social_network/Chat/ChatScreen.dart';

class MyFirebaseMessagingService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('iconpush');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showNotification(String title, String body, String messageText) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '1622228238850543549',
      'Новое сообщение',
      importance: Importance.max,
      priority: Priority.high,
        icon: 'iconpush'
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title ?? 'Default Titl',
        newMessage ?? 'Default Bod',
        platformChannelSpecifics,
        payload: 'item x',
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> onMessageReceived(RemoteMessage message) async {
    print("Notification Data: ${message.data}");

    String title = message.notification?.title ?? 'Новое сообщение';
    String body = message.notification?.body ?? 'Default Body';
    String messageText = message.data['messageText'] ?? '';

    print("Message Text from Data: $messageText");

    showNotification(
      title,
      body,
      messageText,
    );
  }





  Future<void> initializeNotificationChannel() async {
     AndroidNotificationChannel channel = AndroidNotificationChannel(
      '1622228238850543549',
      'Новое сообщение',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
