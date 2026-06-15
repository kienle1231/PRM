// ignore_for_file: avoid_print

/// Firebase Cloud Messaging service for KienCare Mobile Store.
///
/// Handles push notifications: foreground, background, and terminated state.
/// FCM requires a valid Firebase project to function.
///
/// Setup steps:
/// 1. Enable Firebase Cloud Messaging in Firebase Console
/// 2. Configure AndroidManifest.xml with FCM service
/// 3. Replace TODO sections below with actual Firebase imports
class FcmService {
  FcmService._();

  static String? _fcmToken;

  /// The FCM device token for this installation.
  static String? get fcmToken => _fcmToken;

  /// Initialize FCM and request notification permissions.
  static Future<void> initialize() async {
    // TODO: Firebase — Uncomment after Firebase is configured
    // try {
    //   final messaging = FirebaseMessaging.instance;
    //
    //   // Request permission (iOS / Android 13+)
    //   final settings = await messaging.requestPermission(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );
    //
    //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //     _fcmToken = await messaging.getToken();
    //     print('[FCM] Token: $_fcmToken');
    //   }
    //
    //   // Foreground messages
    //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    //   // Background / terminated message tap
    //   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    //
    //   // Check if app was launched from a terminated notification
    //   final initialMessage = await messaging.getInitialMessage();
    //   if (initialMessage != null) {
    //     _handleMessageOpenedApp(initialMessage);
    //   }
    // } catch (e) {
    //   print('[FCM] Initialization failed: $e');
    // }

    print('[FCM] Running in mock mode — Firebase not configured.');
  }

  // TODO: Firebase — Handle foreground message
  // static Future<void> _handleForegroundMessage(RemoteMessage message) async {
  //   print('[FCM] Foreground message: ${message.notification?.title}');
  //   await LocalNotificationService.show(
  //     title: message.notification?.title ?? 'KienCare',
  //     body: message.notification?.body ?? '',
  //   );
  // }

  // TODO: Firebase — Handle notification tap
  // static void _handleMessageOpenedApp(RemoteMessage message) {
  //   print('[FCM] Message opened app: ${message.data}');
  //   // Navigate based on message.data['route']
  // }

  /// Background message handler — must be a top-level function.
  // @pragma('vm:entry-point')
  // static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print('[FCM] Background message: ${message.messageId}');
  // }

  /// Subscribe to a notification topic.
  static Future<void> subscribeToTopic(String topic) async {
    // TODO: Firebase
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('[FCM] Would subscribe to topic: $topic');
  }

  /// Unsubscribe from a notification topic.
  static Future<void> unsubscribeFromTopic(String topic) async {
    // TODO: Firebase
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print('[FCM] Would unsubscribe from topic: $topic');
  }
}
