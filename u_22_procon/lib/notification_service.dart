import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:u_22_procon/main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 初期化
Future<void> initializeNotifications() async {
  // タイムゾーンデータの初期化
  tz.initializeTimeZones();

  // Android用の通知設定
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        debugPrint('通知をタップしました: $payload');
        // 必要に応じて通知のペイロードに基づく処理を追加
        if (payload == 'todo') {
          // グローバルな GoRouter インスタンスを使って遷移
          final router = globalRouter;
          if (router != null) {
            router.go('/todo');
          }
        }
      }
    },
  );
}

// 通知のスケジューリング
Future<void> scheduleReminderNotification(
    String title, String body, DateTime remindDateTime) async {
  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    ),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    tz.TZDateTime.from(remindDateTime, tz.local),
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: 'todo', // 通知をタップしたときに渡す情報
  );
}

// 通知設定をまとめて行う関数
Future<void> setupNotifications() async {
  await initializeNotifications();
  await scheduleReminderNotification(
      'Reminder Title', // タイトル
      'This is a reminder notification', // 本文
      DateTime.now().add(Duration(minutes: 10)) // リマインダー日時
      );
}
