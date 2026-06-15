// ignore_for_file: avoid_print

/// Local notification service for KienCare Mobile Store.
///
/// Displays local push notifications for order updates and promotions.
/// Uses flutter_local_notifications package.
class LocalNotificationService {
  LocalNotificationService._();

  static bool _initialized = false;

  /// Initialize the local notification plugin.
  static Future<void> initialize() async {
    // TODO: flutter_local_notifications setup
    // const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const initSettings = InitializationSettings(android: initSettingsAndroid);
    // await flutterLocalNotificationsPlugin.initialize(
    //   initSettings,
    //   onDidReceiveNotificationResponse: _onNotificationTap,
    // );
    _initialized = true;
    print('[LocalNotif] Initialized (mock mode).');
  }

  /// Show a local notification.
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_initialized) return;

    // TODO: Show real notification
    // const androidDetails = AndroidNotificationDetails(
    //   'kiencare_channel',
    //   'KienCare Notifications',
    //   channelDescription: 'Order updates and promotions',
    //   importance: Importance.high,
    //   priority: Priority.high,
    //   icon: '@mipmap/ic_launcher',
    // );
    // const details = NotificationDetails(android: androidDetails);
    // await flutterLocalNotificationsPlugin.show(id, title, body, details, payload: payload);

    print('[LocalNotif] MOCK NOTIFICATION — $title: $body');
  }

  /// Cancel a notification by ID.
  static Future<void> cancel(int id) async {
    // TODO: await flutterLocalNotificationsPlugin.cancel(id);
    print('[LocalNotif] Cancel notification id=$id');
  }

  /// Cancel all notifications.
  static Future<void> cancelAll() async {
    // TODO: await flutterLocalNotificationsPlugin.cancelAll();
    print('[LocalNotif] Cancel all notifications');
  }
}
