import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/services/notification/notification_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:immolink_mobile/models/Message.dart';
import 'package:immolink_mobile/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.propertyId,
    this.agentId = 0,
    this.fromNotification = false, // NOUVEAU: Indicateur source notification
  });

  final String conversationId;
  final int? propertyId;
  final int agentId;
  final bool fromNotification; // NOUVEAU

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ChatService _chatService = ChatService();
  final TextEditingController textController = TextEditingController();
  String myName = "Demba";
  String imagePath = "";
  Timer? _timer;
  String? playingAudioId;
  List<ChatModel> messages = [];
  bool isLoading = true;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  late AudioPlayer audioPlayer;
  File? file;
  String recordedAudioPath = '';
  bool isRecording = false;
  bool isPlaying = false;
  final recorder = AudioRecorder();
  bool isPause = false;
  bool isAudioLoading = false;
  final Map<String, Duration> audioPositions = {};
  final Map<String, Duration> audioDurations = {};
  final Duration defaultDuration = const Duration(seconds: 1);
  final Map<String, AudioPlayer> audioPlayers = {};
  final Map<String, bool> isPlayingMap = {};
  final Map<String, bool> isPauseMap = {};
  final Map<String, bool> isLoadingMap = {};
  final localStorage = GetStorage();
  var userProfile = AuthRepository.instance.deviceStorage.read('USER_PROFILE');

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _initializeChat();
    _setupFirebaseMessaging();

    // NOUVEAU: Si vient d'une notification, marquer comme lu
    if (widget.fromNotification) {
      _markConversationAsRead();
      _logNotificationOpen();
    }
  }

  // NOUVELLE MÉTHODE: Marquer conversation comme lue
  Future<void> _markConversationAsRead() async {
    try {
      await NotificationServices.instance
          .markNotificationAsRead(widget.conversationId);
      print('📖 Conversation marquée comme lue: ${widget.conversationId}');
    } catch (e) {
      print('❌ Erreur marquage lecture: $e');
    }
  }

  // NOUVELLE MÉTHODE: Logger l'ouverture depuis notification
  void _logNotificationOpen() {
    print('📱 ChatScreen ouvert depuis notification');
    print('ConversationId: ${widget.conversationId}');
    print('AgentId: ${widget.agentId}');
    print('PropertyId: ${widget.propertyId}');
  }

  // MÉTHODE AMÉLIORÉE: Setup Firebase Messaging avec gestion intelligente
  void _setupFirebaseMessaging() {
    _firebaseMessaging.requestPermission();

    // Handle foreground messages - Gestion intelligente selon la conversation
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Message reçu en foreground: ${message.data}');

      if (message.data['conversationId'] == widget.conversationId) {
        // Si le message est pour cette conversation, l'ajouter directement
        _handleNewMessageInCurrentChat(message);
      } else {
        // Sinon, afficher une notification in-app
        _showInAppNotification(message);
      }
    });

    // NOUVEAU: Gestion tap sur notification depuis cette screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTapInChat(message);
    });
  }

  // NOUVELLE MÉTHODE: Gestion message dans chat actuel
  void _handleNewMessageInCurrentChat(RemoteMessage message) {
    try {
      // Ne pas afficher si c'est notre propre message
      final senderName = message.data['senderName'] ?? 'Utilisateur';
      if (senderName == myName) {
        print('🔇 Message ignoré (propre message)');
        return;
      }

      // Créer un ChatModel depuis les données de notification
      final chatModel = ChatModel(
        message.data['content'] ?? message.notification?.body ?? '',
        senderName,
        int.tryParse(message.data['senderId'] ?? '0') ?? 0,
        message.data['messageType'] ?? 'text',
        '', // image
        '', // audio
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Vérifier que le message n'existe pas déjà
      if (!messages.any((msg) =>
          msg.text == chatModel.text &&
          msg.sender_name == chatModel.sender_name)) {
        setState(() {
          messages.insert(0, chatModel);
        });

        print('✅ Message ajouté en temps réel');
        _showMessageReceivedFeedback();
      }
    } catch (e) {
      print('❌ Erreur ajout message temps réel: $e');
    }
  }

  // NOUVELLE MÉTHODE: Feedback visuel pour nouveau message
  void _showMessageReceivedFeedback() {
    // Vibration légère et scroll vers le bas
    // HapticFeedback.lightImpact(); // Décommentez si vous voulez de la vibration

    // Scroll automatique vers le dernier message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Le ListView est en reverse, donc on scroll vers le haut pour voir le nouveau message
      }
    });
  }

  // NOUVELLE MÉTHODE: Notification in-app pour autres conversations
  void _showInAppNotification(RemoteMessage message) {
    if (message.notification != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.chat_bubble,
                      color: Colors.white, size: 20),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.notification!.title ?? '💬 Nouveau message',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.notification!.body ?? '',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.blueGrey,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () {
              _navigateToOtherChat(message.data);
            },
          ),
        ),
      );
    }
  }

  // NOUVELLE MÉTHODE: Navigation vers autre chat
  void _navigateToOtherChat(Map<String, dynamic> data) {
    String conversationId = data['conversationId'] ?? '';
    int agentId = int.tryParse(data['senderId'] ?? '0') ?? 0;
    int? propertyId =
        data['propertyId'] != null ? int.tryParse(data['propertyId']) : null;

    if (conversationId.isNotEmpty) {
      Get.off(() => ChatScreen(
            conversationId: conversationId,
            agentId: agentId,
            propertyId: propertyId,
            fromNotification: true,
          ));
    }
  }

  // NOUVELLE MÉTHODE: Gestion tap notification dans chat
  void _handleNotificationTapInChat(RemoteMessage message) {
    String conversationId = message.data['conversationId'] ?? '';

    if (conversationId != widget.conversationId) {
      // Si c'est une autre conversation, proposer de naviguer
      _showNavigationDialog(message);
    }
    // Si c'est la même conversation, ne rien faire
  }

  // NOUVELLE MÉTHODE: Dialog pour navigation vers autre conversation
  void _showNavigationDialog(RemoteMessage message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Nouvelle conversation'),
          ],
        ),
        content: const Text(
          'Vous avez reçu un message dans une autre conversation. Voulez-vous y accéder ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rester ici'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToOtherChat(message.data);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Aller au chat',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeChat() async {
    myName = userProfile['full_name'];

    if (widget.conversationId.isEmpty && widget.propertyId != null) {
      await _createNewConversation();
    } else {
      await loadMessages();
    }
    setupWebSocket();
  }

  Future<void> _createNewConversation() async {
    try {
      final response = await _chatService.createConversation(
        participants: [],
        propertyId: widget.propertyId!,
        agentId: widget.agentId,
        title: 'New Chat',
      );

      Get.delete<String>(tag: 'conversationId');
      Get.put(response['id'], tag: 'conversationId');

      await loadMessages();
    } catch (e) {
      print('Error creating new conversation: $e');
      Get.snackbar(
        'Error',
        'Unable to start chat. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String get currentConversationId {
    return widget.conversationId.isNotEmpty
        ? widget.conversationId
        : Get.find<String>(tag: 'conversationId');
  }

  void setupWebSocket() {
    _chatService.messageStream?.listen((message) {
      final parsedMessage = json.decode(message);

      if (parsedMessage['type'] == 'new_message') {
        print(
            "Got WebSocket message: ${parsedMessage} and currentConversation is $currentConversationId");

        if (parsedMessage['message']['conversation'] == currentConversationId) {
          if (parsedMessage['message']['sender_name'] != myName) {
            // CORRECTION: Vérifier par ID unique du message
            final messageId = parsedMessage['message']['_id'] ??
                parsedMessage['message']['id'];
            final messageExists = messages.any((msg) => msg.id == messageId);

            if (!messageExists) {
              setState(() {
                messages.insert(
                    0, ChatModel.fromJson(parsedMessage['message']));
              });
              print('✅ Message WebSocket ajouté: $messageId');
            } else {
              print('🔄 Message WebSocket ignoré (déjà existant): $messageId');
            }
          }
        }
      } else if (parsedMessage['type'] == 'connection_established') {
        print('Connection established with user: ${parsedMessage['user']}');
        _chatService.joinRoom(currentConversationId);
      } else {
        print('Received other message type: ${parsedMessage['type']}');
      }
    });
  }

  Future<void> loadMessages() async {
    try {
      final data = await _chatService.getMessages(currentConversationId);
      setState(() {
        messages = data.map((json) => ChatModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage(String content, String type,
      {String? filePath, Duration? duration}) async {
    try {
      File? mediaFile;
      String messageContent = content;

      if (filePath != null) {
        mediaFile = File(filePath);
        messageContent = type == 'image' ? '📷 Image' : '🎵 Audio';
      }

      final response = await _chatService.sendMessage(
        conversationId: currentConversationId,
        content: messageContent,
        type: type,
        media: mediaFile,
        duration: Duration(seconds: _recordingDuration),
      );

      setState(() {
        messages.insert(0, ChatModel.fromJson(response));
      });
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    audioPlayer.dispose();
    _timer?.cancel();
    _recordingTimer?.cancel();

    // Nettoyer les audio players
    for (var player in audioPlayers.values) {
      player.dispose();
    }

    super.dispose();
  }

  // MÉTHODE AMÉLIORÉE: AppBar avec informations et actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blueGrey,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💬 Immo Place",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.fromNotification)
            const Text(
              "📱 Depuis notification",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
      actions: [
        // NOUVEAU: Bouton info conversation
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: _showChatInfo,
        ),
        // NOUVEAU: Menu d'actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_notifications',
              child: Row(
                children: [
                  Icon(Icons.notifications_off),
                  SizedBox(width: 8),
                  Text('Effacer notifications'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Actualiser'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // NOUVELLE MÉTHODE: Gestion des actions du menu
  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_notifications':
        _markConversationAsRead();
        Get.snackbar('✅', 'Notifications effacées',
            duration: const Duration(seconds: 2));
        break;
      case 'refresh':
        loadMessages();
        Get.snackbar('🔄', 'Messages actualisés',
            duration: const Duration(seconds: 2));
        break;
    }
  }

  // NOUVELLE MÉTHODE: Afficher infos du chat
  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.green),
            SizedBox(width: 8),
            Text('Information du Chat'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('💬 ID Conversation', widget.conversationId),
              _buildInfoRow('👤 Agent ID', widget.agentId.toString()),
              if (widget.propertyId != null)
                _buildInfoRow('🏠 Propriété ID', widget.propertyId.toString()),
              _buildInfoRow('📱 Depuis notification',
                  widget.fromNotification ? "Oui" : "Non"),
              _buildInfoRow(
                  '💬 Nombre de messages', messages.length.toString()),
              _buildInfoRow('👨‍💼 Mon nom', myName),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  // NOUVEAU: Indicateur si vient d'une notification
                  if (widget.fromNotification)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.green.shade100,
                      child: const Row(
                        children: [
                          Icon(Icons.notifications_active,
                              color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('Chat ouvert depuis une notification',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        var message = messages[index];

                        if (message.kind == 'text') {
                          return BubbleSpecialThree(
                            isSender: message.sender_name == myName,
                            text: message.text,
                            color: message.sender_name == myName
                                ? Colors.blueGrey
                                : Colors.black45,
                            tail: true,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        } else if (message.kind == 'image') {
                          return BubbleNormalImage(
                            id: message.image,
                            isSender: message.sender_name == myName,
                            image: Image.network(message.image),
                          );
                        } else if (message.kind == 'audio') {
                          final position =
                              audioPositions[message.audio] ?? Duration.zero;
                          final duration =
                              audioDurations[message.audio] ?? defaultDuration;
                          final isPlayingThis =
                              isPlayingMap[message.audio] ?? false;
                          final isPauseThis =
                              isPauseMap[message.audio] ?? false;
                          final isLoadingThis =
                              isLoadingMap[message.audio] ?? false;

                          return GestureDetector(
                            onTap: () =>
                                _playAudio(message.audio, message.audio),
                            child: BubbleNormalAudio(
                              color: message.sender_name == myName
                                  ? Colors.blue
                                  : Colors.blueGrey,
                              isSender: message.sender_name == myName,
                              duration: duration.inSeconds.toDouble(),
                              position: position.inSeconds.toDouble(),
                              isPlaying: isPlayingThis,
                              isLoading: isLoadingThis,
                              isPause: isPauseThis,
                              onSeekChanged: (newPosition) {
                                _changeSeek(newPosition, message.audio);
                              },
                              onPlayPauseButtonClick: () {
                                _playAudio(message.audio, message.audio);
                              },
                              sent: message.sender_name == myName,
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  _buildInputArea(context)
                ],
              ),
            ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => showBottomSheet(context),
              icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  cursorColor: Colors.green,
                  controller: textController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            textController.text.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (!isRecording) {
                            startRecording();
                          } else {
                            stopRecording();
                          }
                        });
                      },
                      icon: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          sendMessage(textController.text.trim(), 'text');
                          textController.clear();
                        }
                      },
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Toutes les autres méthodes restent identiques...
  Future<void> _playAudio(String audioPath, String audioId) async {
    if (!audioPlayers.containsKey(audioId)) {
      audioPlayers[audioId] = AudioPlayer();

      audioPlayers[audioId]!.onDurationChanged.listen((Duration duration) {
        setState(() {
          audioDurations[audioId] = duration;
        });
      });

      audioPlayers[audioId]!.onPositionChanged.listen((Duration p) {
        setState(() {
          audioPositions[audioId] = p;

          if (p >= (audioDurations[audioId] ?? Duration.zero)) {
            _resetAudioState(audioId);
          }
        });
      });

      audioPlayers[audioId]!.onPlayerComplete.listen((_) {
        _resetAudioState(audioId);
      });
    }

    final player = audioPlayers[audioId]!;

    if (isPlayingMap[audioId] == true) {
      await player.pause();
      setState(() {
        isPlayingMap[audioId] = false;
        isPauseMap[audioId] = true;
      });
    } else {
      for (var entry in audioPlayers.entries) {
        if (entry.key != audioId && isPlayingMap[entry.key] == true) {
          await entry.value.stop();
          _resetAudioState(entry.key);
        }
      }

      setState(() {
        isLoadingMap[audioId] = true;
        isPauseMap[audioId] = false;
      });

      try {
        if (isPauseMap[audioId] == true) {
          await player.resume();
        } else {
          await player.play(UrlSource(audioPath));
        }

        setState(() {
          isPlayingMap[audioId] = true;
          isLoadingMap[audioId] = false;
        });
      } catch (e) {
        print('Error playing audio: $e');
        _resetAudioState(audioId);
      }
    }
  }

  void _resetAudioState(String audioId) {
    setState(() {
      isPlayingMap[audioId] = false;
      isPauseMap[audioId] = false;
      isLoadingMap[audioId] = false;
      audioPositions[audioId] = Duration.zero;
    });
  }

  void _changeSeek(double value, String audioId) {
    final currentDuration = audioDurations[audioId] ?? defaultDuration;
    if (value <= currentDuration.inSeconds &&
        audioPlayers.containsKey(audioId)) {
      final newPosition = Duration(seconds: value.toInt());
      audioPlayers[audioId]!.seek(newPosition);
      setState(() {
        audioPositions[audioId] = newPosition;
      });
    }
  }

  Future<void> startRecording() async {
    final location = await getApplicationDocumentsDirectory();
    String fileName = const Uuid().v1();

    recordedAudioPath = '${location.path}/$fileName.m4a';
    if (await recorder.hasPermission()) {
      await recorder.start(const RecordConfig(), path: recordedAudioPath);
      setState(() {
        isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });

        if (_recordingDuration >= 180) {
          stopRecording();
          Get.snackbar(
            'Recording Stopped',
            'Recording exceeded 3 minutes and has been stopped.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    }
  }

  Future<void> stopRecording() async {
    String? finalPath = await recorder.stop();
    _recordingTimer?.cancel();
    if (finalPath != null) {
      setState(() {
        recordedAudioPath = finalPath;
        isRecording = false;
      });
      await sendMessage('', 'audio',
          filePath: recordedAudioPath,
          duration: Duration(seconds: _recordingDuration));
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              onTap: () {
                openImageCamera(context);
              },
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Appareil photo'),
            ),
            ListTile(
              onTap: () {
                openImageGallery(context);
              },
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galerie'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> openImageGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      await sendMessage('', 'image', filePath: image.path);
      Navigator.pop(context);
    }
  }

  Future<void> openImageCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      await sendMessage('', 'image', filePath: image.path);
      Navigator.pop(context);
    }
  }

  // MÉTHODE CONSERVÉE MAIS SIMPLIFIÉE: Navigation vers autre chat
  void _navigateToChatScreen(Map<String, dynamic> data) {
    String conversationId = data['conversationId'] ?? '';
    int? propertyId =
        data['propertyId'] != null ? int.tryParse(data['propertyId']) : null;
    int agentId = int.tryParse(data['senderId'] ?? '0') ?? 0;

    if (conversationId.isNotEmpty) {
      Get.off(() => ChatScreen(
            conversationId: conversationId,
            propertyId: propertyId,
            agentId: agentId,
            fromNotification: true,
          ));
    }
  }
}
