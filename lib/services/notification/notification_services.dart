import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/views/screens/chat_screen.dart';
import 'dart:convert';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationServices.instance.setupFlutterNotifications();
  print('📱 Message en arrière-plan: ${message.notification?.title}');
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
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('APNS_TOKEN: $apnsToken');

      // CORRECTION PRINCIPALE: Récupérer ET stocker le FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM_TOKEN récupéré: $fcmToken');

      // STOCKER le token dans le localStorage
      if (fcmToken != null) {
        deviceStorage.write('FCM_TOKEN', fcmToken);
        print('FCM_TOKEN stocké: ${deviceStorage.read('FCM_TOKEN')}');
      } else {
        print('⚠️ ERREUR: FCM Token est null !');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _setupMessageHandlers();
      await setupFlutterNotifications();

      print('✅ NotificationServices complètement initialisé');
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterNotificationsInitialized) {
      return;
    }

    //Android setup
    const channel = AndroidNotificationChannel(
        'high_importance_channel', 'Chat Notifications',
        description: 'Notifications pour les messages de chat ImmoLink',
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

    await _localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );
    _isFlutterNotificationsInitialized = true;
  }

  // NOUVELLE MÉTHODE: Gestion du tap sur notification locale
  static void _onNotificationTap(NotificationResponse response) {
    print('📱 Notification locale tappée: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!);
        NotificationServices.instance._navigateToChatScreen(data);
      } catch (e) {
        print('❌ Erreur parsing payload notification: $e');
      }
    }
  }

  // MÉTHODE MODIFIÉE: Notification personnalisée avec emojis et couleurs
  Future<void> showNotifications(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        // Titre et corps personnalisés
        String customTitle = notification.title ?? '💬 Nouveau message';
        String customBody = notification.body ?? 'Vous avez reçu un nouveau message';

        // Ajouter des emojis selon le type de message
        if (message.data['messageType'] == 'image') {
          customBody = '📷 ' + customBody;
        } else if (message.data['messageType'] == 'audio') {
          customBody = '🎵 ' + customBody;
        } else {
          customBody = '💬 ' + customBody;
        }

        await _localNotification.show(
          notification.hashCode,
          customTitle,
          customBody,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Chat Notifications',
              channelDescription: 'Notifications pour les messages de chat ImmoLink',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'im_place_icon',
              // AJOUTS: Personnalisation visuelle
              color: const Color(0xFF4CAF50), // Vert
              colorized: true,
              playSound: true,
              enableVibration: true,
              // Actions de notification
              actions: <AndroidNotificationAction>[
                const AndroidNotificationAction(
                  'reply',
                  '💬 Répondre',
                  allowGeneratedReplies: true,
                  inputs: <AndroidNotificationActionInput>[
                    AndroidNotificationActionInput(
                      label: 'Tapez votre réponse...',
                    ),
                  ],
                ),
                const AndroidNotificationAction(
                  'mark_read',
                  '✅ Marquer comme lu',
                ),
              ],
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
            ),
          ),
          // IMPORTANT: Payload avec données de navigation
          payload: jsonEncode(message.data),
        );
        print('✅ Notification personnalisée affichée');
      }
    } catch (e) {
      print('❌ Erreur affichage notification: $e');
    }
  }

  // MÉTHODE MODIFIÉE: Setup des handlers avec navigation personnalisée
  Future<void> _setupMessageHandlers() async {
    try {
      // Foreground message - Afficher notification personnalisée
      FirebaseMessaging.onMessage.listen((message) {
        print('📱 Message reçu en foreground: ${message.notification?.title}');
        showNotifications(message);
      });

      // Background message - Navigation vers conversation
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // App opened from terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📱 App ouverte depuis une notification');
        _handleNotificationTap(initialMessage);
      }

      print('✅ Message handlers configurés');
    } catch (e) {
      print('❌ Erreur configuration message handlers: $e');
    }
  }

  // MÉTHODE MODIFIÉE: Gestion intelligente des notifications
  void _handleBackgroundMessage(RemoteMessage message) {
    print('📱 Handling background message: ${message.data}');
    if (message.data['type'] == 'chat') {
      _navigateToChatScreen(message.data);
    }
  }

  // NOUVELLE MÉTHODE: Gestion du tap sur notification Firebase
  void _handleNotificationTap(RemoteMessage message) {
    print('📱 Notification Firebase tappée: ${message.data}');

    if (message.data['type'] == 'chat') {
      _navigateToChatScreen(message.data);
    }
  }

  // NOUVELLE MÉTHODE: Navigation intelligente vers ChatScreen
  void _navigateToChatScreen(Map<String, dynamic> data) {
    try {
      String conversationId = data['conversationId'] ?? '';
      String agentIdStr = data['senderId'] ?? '0';
      int agentId = int.tryParse(agentIdStr) ?? 0;

      print('🔄 Tentative navigation - ConversationId: $conversationId, AgentId: $agentId');

      if (conversationId.isNotEmpty) {
        // Vérifier si l'app est prête pour la navigation
        if (Get.context != null) {
          Get.to(() => ChatScreen(
            conversationId: conversationId,
            agentId: agentId,
            fromNotification: true,
          ));
          print('✅ Navigation vers ChatScreen réussie');
        } else {
          // Si Get.context n'est pas prêt, attendre un peu et réessayer
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.context != null) {
              Get.to(() => ChatScreen(
                conversationId: conversationId,
                agentId: agentId,
                fromNotification: true,
              ));
              print('✅ Navigation vers ChatScreen différée réussie');
            } else {
              print('❌ Get.context toujours null après délai');
            }
          });
        }
      } else {
        print('❌ ConversationId manquant dans les données de notification');
        _showErrorSnackbar('ID de conversation manquant');
      }
    } catch (e) {
      print('❌ Erreur navigation vers chat: $e');
      _showErrorSnackbar('Erreur lors de l\'ouverture du chat');
    }
  }

  // NOUVELLE MÉTHODE: Afficher message d'erreur
  void _showErrorSnackbar(String message) {
    if (Get.context != null) {
      Get.snackbar(
        '❌ Erreur',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // NOUVELLE MÉTHODE: Vérifier si dans une conversation spécifique
  bool isInConversation(String conversationId) {
    // Vérifier si l'utilisateur est actuellement dans cette conversation
    try {
      final currentRoute = Get.currentRoute;
      return currentRoute.contains('ChatScreen') &&
          Get.arguments != null &&
          Get.arguments['conversationId'] == conversationId;
    } catch (e) {
      return false;
    }
  }

  // NOUVELLE MÉTHODE: Marquer notification comme lue
  Future<void> markNotificationAsRead(String conversationId) async {
    try {
      // Supprimer les notifications pour cette conversation
      await _localNotification.cancel(conversationId.hashCode);
      print('✅ Notifications supprimées pour conversation: $conversationId');
    } catch (e) {
      print('❌ Erreur suppression notifications: $e');
    }
  }

  Future<void> initNotification() async {
    await initialize();
  }

  Future<String?> getCurrentFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        deviceStorage.write('FCM_TOKEN', fcmToken);
      }
      return fcmToken;
    } catch (e) {
      print('Erreur lors de la récupération du FCM token: $e');
      return null;
    }
  }

  Future<void> refreshFCMToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      final newToken = await FirebaseMessaging.instance.getToken();
      if (newToken != null) {
        deviceStorage.write('FCM_TOKEN', newToken);
        print('FCM Token rafraîchi: $newToken');
      }
    } catch (e) {
      print('Erreur lors du refresh du FCM token: $e');
    }
  }

  // NOUVELLE MÉTHODE: Debug des notifications
  Future<void> debugNotificationStatus() async {
    print('=== DEBUG NOTIFICATION STATUS ===');

    final settings = await _firebaseMessaging.getNotificationSettings();
    print('Statut autorisation: ${settings.authorizationStatus}');
    print('Alert activé: ${settings.alert}');
    print('Badge activé: ${settings.badge}');
    print('Sound activé: ${settings.sound}');

    final fcmToken = deviceStorage.read('FCM_TOKEN');
    print('FCM Token stocké: ${fcmToken != null ? "✅ Présent" : "❌ Absent"}');

    print('Flutter notifications initialisées: $_isFlutterNotificationsInitialized');
    print('=== FIN DEBUG ===');
  }

  // NOUVELLE MÉTHODE: Test de notification
  Future<void> testNotification() async {
    try {
      await _localNotification.show(
        12345,
        '🧪 Test Notification',
        '✅ Les notifications fonctionnent correctement !',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Test Notifications',
            channelDescription: 'Test des notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'im_place_icon',
            color: Color(0xFF4CAF50),
            colorized: true,
          ),
        ),
        payload: jsonEncode({'type': 'test', 'message': 'Test réussi'}),
      );
      print('✅ Notification de test envoyée');
    } catch (e) {
      print('❌ Erreur test notification: $e');
    }
  }
}