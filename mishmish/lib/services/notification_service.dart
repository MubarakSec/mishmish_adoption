import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: initSettings);

    // Request permissions on Android 13+ if applicable
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  static Future<void> showOtpNotification(String otp) async {
    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'إشعارات رمز التحقق',
      channelDescription: 'قناة إرسال رمز التحقق لتطبيق مشمش',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 1001,
      title: 'مشمش - رمز التحقق (OTP)',
      body: 'رمز التحقق الخاص بك هو: $otp',
      notificationDetails: details,
    );
  }
}
