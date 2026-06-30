import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    await _createAndroidChannel();
    await registerAndSaveToken();
    _listenToMessages();
  }

  static Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked payload: ${response.payload}');
      },
    );
  }

  static Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'noon_orders',
      'Order Notifications',
      description: 'Notifications for order updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<String> _registerToken() async {
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    return token ?? '';
  }

  static Future<void> registerAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No logged in user, FCM token not saved');
      return;
    }

    final token = await _registerToken();

    if (token.isEmpty) {
      print('FCM token is empty');
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('FCM token saved for user: ${user.uid}');
  }

  static void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from notification: ${message.notification?.title}');
      print('Notification data: ${message.data}');
    });

    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated notification: ${message.data}');
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': newToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('FCM token refreshed and saved: $newToken');
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      print('Notification is null');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'noon_orders',
      'Order Notifications',
      channelDescription: 'Notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF004D26),
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
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
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}