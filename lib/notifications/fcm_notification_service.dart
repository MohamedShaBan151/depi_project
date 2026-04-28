import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    await _registerToken();
    _listenToMessages();
  }

  static Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(settings);
  }

  static Future<String> _registerToken() async {
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    return token ?? '';
  }

  static void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from notification: ${message.notification?.title}');
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'noon_orders',
      'Order Notifications',
      channelDescription: 'Notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF004D26),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.notification?.hashCode ?? 0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  static Future<void> sendOrderNotification({
    required String orderId,
    required String status,
  }) async {
    final titles = {
      'confirmed': 'Order Confirmed',
      'processing': 'Order Being Prepared',
      'shipped': 'Order Shipped',
      'outForDelivery': 'Out for Delivery',
      'delivered': 'Order Delivered',
    };

    final bodies = {
      'confirmed': 'Your order #$orderId has been confirmed',
      'processing': 'Your order #$orderId is being prepared',
      'shipped': 'Your order #$orderId has been shipped',
      'outForDelivery': 'Your order #$orderId is out for delivery',
      'delivered': 'Your order #$orderId has been delivered',
    };

    await _localNotifications.show(
      orderId.hashCode,
      titles[status] ?? 'Order Update',
      bodies[status] ?? 'Order #$orderId status: $status',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'noon_orders',
          'Order Notifications',
          channelDescription: 'Notifications for order updates',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF004D26),
        ),
      ),
    );
  }
}