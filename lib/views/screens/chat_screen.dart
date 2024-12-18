import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:immolink_mobile/models/Message.dart';
import 'package:immolink_mobile/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.propertyId,  // Add propertyId parameter
    this.agentId=0,
  });

  final String conversationId;
  final int? propertyId;
  final int agentId;// Make it optional for existing conversations

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController textController = TextEditingController();
  String myName = "Demba";
  String imagePath = "";
  Timer? _timer;
  String? playingAudioId;
  List<ChatModel> messages = [];
  bool isLoading = true;
  Timer? _recordingTimer; // Timer to track recording duration
  int _recordingDuration = 0;
  late AudioPlayer audioPlayer;
  File? file;
  String recordedAudioPath = '';
  bool isRecording = false;
  bool isPlaying = false;
  final recorder = AudioRecorder();
  bool isPause = false;
  bool isAudioLoading = false;
  // Add a map to store positions for each audio message
  final Map<String, Duration> audioPositions = {};
  // Add a map to store durations for each audio message
  final Map<String, Duration> audioDurations = {};
  final Duration defaultDuration = const Duration(seconds: 1);
  final Map<String, AudioPlayer> audioPlayers = {};
  final Map<String, bool> isPlayingMap = {};
  final Map<String, bool> isPauseMap = {};
  final Map<String, bool> isLoadingMap = {};
  final localStorage = GetStorage();
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _initializeChat();
    //setupWebSocket();
  }

  Future<void> _initializeChat() async {
    myName = await localStorage.read('FULL_NAME');
    if (widget.conversationId.isEmpty && widget.propertyId != null) {
      // Create new conversation if we have propertyId but no conversationId
      await _createNewConversation();
    } else {
      // Load existing conversation
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

      // Update the widget's conversationId using GetX
      Get.delete<String>(tag: 'conversationId');
      Get.put(response['id'], tag: 'conversationId');

      // Now load messages for the new conversation
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
    // Get either the widget's conversationId or the newly created one
    return widget.conversationId.isNotEmpty
        ? widget.conversationId
        : Get.find<String>(tag: 'conversationId');
  }

  void setupWebSocket() {
    _chatService.messageStream?.listen((message) {
      // Parse the message from JSON
      final parsedMessage = json.decode(message);

      // Check the type of the message
      if (parsedMessage['type'] == 'new_message') {
        // Check if the conversationId matches
        print("Got new message: ${parsedMessage} and currentConverstion is $currentConversationId");
        if (parsedMessage['message']['conversation'] == currentConversationId) {
          if (!messages.any((msg) => msg.id == parsedMessage['message']['id'])) {
            setState(() {
              messages.insert(0, ChatModel.fromJson(parsedMessage['message']));
            });
          }
        }
      } else if (parsedMessage['type'] == 'connection_established') {
        // Handle connection established message if needed
        print('Connection established with user: ${parsedMessage['user']}');
        _chatService.joinRoom(currentConversationId);
      } else {
        // Handle other message types if necessary
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

  Future<void> sendMessage(String content, String type, {String? filePath, Duration? duration}) async {
    try {
      File? mediaFile;
      String messageContent = content;

      if (filePath != null) {
        mediaFile = File(filePath);
        // Set a default content for media messages
        messageContent = type == 'image' ? '📷 Image' : '🎵 Audio';
      }

      final response = await _chatService.sendMessage(
        conversationId: currentConversationId,
        content: messageContent,  // Use the messageContent instead of content
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Conversation"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: Column(
          children: [
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
                          ? Colors.green
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
                    final position = audioPositions[message.audio] ?? Duration.zero;
                    final duration = audioDurations[message.audio] ?? defaultDuration;
                    final isPlayingThis = isPlayingMap[message.audio] ?? false;
                    final isPauseThis = isPauseMap[message.audio] ?? false;
                    final isLoadingThis = isLoadingMap[message.audio] ?? false;

                    return GestureDetector(
                      onTap: () => _playAudio(message.audio, message.audio),
                      child: BubbleNormalAudio(
                        color: message.sender_name == myName ? Colors.blue : Colors.green,
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
      color: Colors.black12,
      height: 100,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          IconButton(
            onPressed: () => showBottomSheet(context),
            icon: const Icon(Icons.add, color: Colors.green),
          ),
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              controller: textController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  // This will trigger a rebuild when the text changes
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          textController.text.isEmpty
              ? CircleAvatar(
            backgroundColor: Colors.green,
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
              ),
            ),
          )
              : IconButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                sendMessage(textController.text.trim(), 'text');
                textController.clear();
              }
            },
            icon: const Icon(Icons.send, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Future<void> _playAudio(String audioPath, String audioId) async {
    // Create a new audio player if it doesn't exist for this message
    if (!audioPlayers.containsKey(audioId)) {
      audioPlayers[audioId] = AudioPlayer();

      // Set up duration listener for this specific player
      audioPlayers[audioId]!.onDurationChanged.listen((Duration duration) {
        setState(() {
          audioDurations[audioId] = duration;
        });
      });

      // Set up position listener for this specific player
      audioPlayers[audioId]!.onPositionChanged.listen((Duration p) {
        setState(() {
          audioPositions[audioId] = p;

          // Check if audio has finished playing
          if (p >= (audioDurations[audioId] ?? Duration.zero)) {
            _resetAudioState(audioId);
          }
        });
      });

      // Add completion listener
      audioPlayers[audioId]!.onPlayerComplete.listen((_) {
        _resetAudioState(audioId);
      });
    }

    final player = audioPlayers[audioId]!;

    if (isPlayingMap[audioId] == true) {
      // Pause the currently playing audio
      await player.pause();
      setState(() {
        isPlayingMap[audioId] = false;
        isPauseMap[audioId] = true;
      });
    } else {
      // Stop all other playing audio first
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
    if (value <= currentDuration.inSeconds && audioPlayers.containsKey(audioId)) {
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
      // Start a timer to track the recording duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });

        // Stop recording if it exceeds 3 minutes (180 seconds)
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
      await sendMessage('', 'audio', filePath: recordedAudioPath, duration: Duration(seconds: _recordingDuration));
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (c) => IntrinsicHeight(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              Card(
                color: Colors.grey.shade900,
                child: ListTile(
                  onTap: () {
                    openImageCamera(context);
                  },
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text('Camera',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Card(
                color: Colors.grey.shade900,
                child: ListTile(
                  onTap: () {
                    openImageGallery(context);
                  },
                  leading: const Icon(Icons.photo, color: Colors.white),
                  title: const Text('Gallery',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
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
}