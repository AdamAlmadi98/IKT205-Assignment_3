import 'package:flutter/foundation.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime createdAt;

  AppNotification({
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

class NotificationStore {
  static final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier([]);

  static void addNotification({
    required String title,
    required String body,
  }) {
    notifications.value = [
      AppNotification(
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
      ...notifications.value,
    ];
  }

  static void clearNotifications() {
    notifications.value = [];
  }
}