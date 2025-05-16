import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize notification settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // Initialize notification settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          // Navigate to event details when notification is tapped
          // This is handled in the app
        }
      },
    );

    // Request permissions for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Schedule a notification for an event
  Future<void> scheduleEventNotification(Event event) async {
    // Notification should be 30 minutes before the event
    final scheduledTime = tz.TZDateTime.from(
      event.dueDate.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        event.id ?? 0, // Use event ID as notification ID
        'Upcoming Event: ${event.title}',
        'Your event is scheduled for ${_formatTime(event.dueDate)}',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'event_channel',
            'Event Notifications',
            channelDescription: 'Notifications for upcoming events',
            importance: Importance.high,
            priority: Priority.high,
            color: _getCategoryColor(event.category),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true, // Required parameter added
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: event.id.toString(), // Set event ID as payload
      );
    }
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Format time for notification message
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get color for notification based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFF1976D2); // Blue
      case 'Personal':
        return const Color(0xFF388E3C); // Green
      case 'Health':
        return const Color(0xFFD32F2F); // Red
      case 'Shopping':
        return const Color(0xFF7B1FA2); // Purple
      case 'Social':
        return const Color(0xFFF57C00); // Orange
      case 'Study':
        return const Color(0xFF00796B); // Teal
      default:
        return const Color(0xFF616161); // Grey
    }
  }
}
