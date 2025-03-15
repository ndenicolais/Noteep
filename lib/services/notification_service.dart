import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> behaviorSubject = BehaviorSubject<String?>();
  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        behaviorSubject.add(response.payload);
      },
    );

    // Listen for changes in Firestore and update local notifications
    notificationsCollection.snapshots().listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        var data = docChange.doc.data() as Map<String, dynamic>;
        if (docChange.type == DocumentChangeType.added ||
            docChange.type == DocumentChangeType.modified) {
          scheduleNotification(
            data['notificationId'],
            (data['scheduledDateTime'] as Timestamp).toDate(),
            data['title'],
            data['body'],
            data['payload'],
          );
        } else if (docChange.type == DocumentChangeType.removed) {
          cancelNotification(data['notificationId']);
        }
      }
    });
  }

  Future<void> scheduleNotification(
    int notificationId,
    DateTime scheduledDateTime,
    String title,
    String body,
    String payload,
  ) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Save notification details to Firestore
    await notificationsCollection.doc(notificationId.toString()).set({
      'notificationId': notificationId,
      'scheduledDateTime': scheduledDateTime,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    await notificationsCollection.doc(notificationId.toString()).delete();
  }
}
