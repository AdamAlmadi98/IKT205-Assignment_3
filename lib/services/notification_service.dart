import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // plugin for lokale notifikasjoner
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('ic_stat_notify');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    // initialiserer notifikasjonssystemet
    await _plugin.initialize(initSettings);

    // ber om tillatelse til å sende varsler
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'note_notifications',
      'Note Notifications',
      channelDescription: 'Notifications when a new note is saved',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_notify',
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    // viser selve notifikasjonen
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}