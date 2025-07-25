import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:immolink_mobile/utils/config.dart';

import 'notification/notification_services.dart';

class ChatService {
  ChatService() {
    connectWebSocket(); // Call the method to connect to WebSocket
  }
  final String baseUrl = 'https://${Config.chatHostApi}/api/chat';
  final String wsUrl = 'wss://${Config.chatHostApi}/ws';

  final localStorage = GetStorage();
  WebSocketChannel? _channel;


  Map<String, String> get _headers {
    final token = localStorage.read('AUTH_TOKEN');
    final fcmTokenRaw = localStorage.read("FCM_TOKEN");

    String fcmToken = '';

    if (fcmTokenRaw != null && fcmTokenRaw.toString().isNotEmpty) {
      fcmToken = fcmTokenRaw.toString();
    } else {
      // CORRECTION: Si FCM token manquant, déclencher régénération
      print('⚠️ FCM_TOKEN manquant, régénération en cours...');
      _regenerateFCMToken();
      fcmToken = ''; // Temporaire, sera régénéré
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Fcm-Token': fcmToken,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // NOUVELLE MÉTHODE: Régénération FCM token
  Future<void> _regenerateFCMToken() async {
    try {
      await NotificationServices.instance.getCurrentFCMToken();
      print('✅ FCM Token régénéré');
    } catch (e) {
      print('❌ Erreur régénération FCM: $e');
    }
  }


  // Connect to WebSocket
  void connectWebSocket() {
    final token = localStorage.read('AUTH_TOKEN');
    final fcmToken = localStorage.read('FCM_TOKEN');
    if (token != null) {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$token&fcmToken=$fcmToken'),
      );
    }
  }

  // Get all conversations
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load conversations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  // Create a new conversation
  Future<dynamic> createConversation({
    required List<int> participants,
    required int propertyId,
    required int agentId,
    String? title,
  }) async {
    try {
      print('ChatService.createConversation appelé avec:');
      print('- PropertyId: $propertyId');
      print('- AgentId: $agentId');
      print('- Title: $title');
      print('- Participants: $participants');

      final body = {
        'participants': participants,
        'propertyId': propertyId,
        'agentId': agentId,
        'title': title ?? 'Conversation',
      };

      print('Corps de la requête: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: _headers,
        body: json.encode(body),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de création de conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur détaillée dans ChatService.createConversation: $e');
      throw Exception('Échec de création de conversation: $e');
    }
  }

  // Get messages for a conversation
  Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Send a message
  Future<dynamic> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    File? media,
    Duration? duration,
  }) async {
    try {
      if (media != null) {
        // Handle file upload with multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/messages'),
        );

        // Add headers
        request.headers.addAll(_headers);

        // Add text fields
        request.fields['conversationId'] = conversationId;
        request.fields['content'] = content;
        request.fields['type'] = type;
        request.fields['duration'] = duration?.inSeconds.toString() ?? '0';

        // Add file
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          media.path,
        ));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to send message: ${response.body}');
        }
      } else {
        // Simple text message
        final response = await http.post(
          Uri.parse('$baseUrl/messages'),
          headers: _headers,
          body: json.encode({
            'conversationId': conversationId,
            'content': content,
            'type': type,
          }),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to send message: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Listen to WebSocket messages
  Stream<dynamic>? get messageStream => _channel?.stream.asBroadcastStream();

  Future<void> joinRoom(String conversationId) async {
    if (_channel != null) {
      final message = {
        'type': 'join_room',
        'conversationId': conversationId,
      };

      // Send the join room message
      _channel!.sink.add(json.encode(message));
    } else {
      throw Exception('WebSocket is not connected');
    }
  }
  // Close WebSocket connection
  void dispose() {
    _channel?.sink.close();

  }
}