// Notification service – requires firebase_messaging.
// Enable when Firebase is configured.
//
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class NotificationService {
//   static final _messaging = FirebaseMessaging.instance;
//
//   static Future<void> init() async {
//     await _messaging.requestPermission();
//     final token = await _messaging.getToken();
//     debugPrint('FCM Token: $token');
//     FirebaseMessaging.onMessage.listen((msg) {
//       debugPrint('Foreground message: ${msg.notification?.title}');
//     });
//   }
// }

class NotificationService {
  static Future<void> init() async {
    // No-op until Firebase is configured.
  }
}
