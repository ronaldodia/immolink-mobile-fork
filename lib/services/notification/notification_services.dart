import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationServices.instance.setupFlutterNotifications();
  await NotificationServices.instance.setupFlutterNotifications();
}

class NotificationServices {
  NotificationServices._();
  static final NotificationServices instance = NotificationServices._();
  //Create an instance Firebase Messaging;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();
  bool _isFlutterNotificationsInitialized = false;
  final deviceStorage = GetStorage();

  Future<void> initialize() async {

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();

    await _setupMessageHandlers();

    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM_TOKEN: $fcmToken');
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);

    print('Permission status: ${settings.authorizationStatus}');
  }


  Future<void> setupFlutterNotifications() async {
    if (_isFlutterNotificationsInitialized) {
      return;
    }

    //Android setup
    const channel = AndroidNotificationChannel(
        'high_importance_channel', 'High Importance Notifications',
        description: 'This chanel is used for important notifications.',
        importance: Importance.high);
    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('im_place_icon');

    //IOS setup
    const initializationSettingDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingDarwin);

    await _localNotification.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (details) {});
    _isFlutterNotificationsInitialized = true;
  }

  Future<void> showNotifications(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotification.show(notification.hashCode, notification.title,
          notification.body, const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifcations',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'im_place_icon',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        payload: message.data.toString()
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
      //foreground message
    FirebaseMessaging.onMessage.listen((message){
      showNotifications(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if(initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if(message.data['type'] == 'chat') {

      // open chat screen
    }
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    deviceStorage.write('FCM_TOKEN', fcmToken);
    print('FCM_TOKEN: ${deviceStorage.read('FCM_TOKEN')}');
  }
}
