import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:immolink_mobile/models/ChatModel.dart';
import 'package:immolink_mobile/const/chat.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textController = TextEditingController();
  String myName = "Demba";
  String imagePath = "";
  Timer? _timer;
  String?
      playingAudioId; // Pour stocker l'ID de l'audio actuellement en lecture

  late AudioPlayer audioPlayer;
  File? file;
  String recordedAudioPath = '';
  bool isRecording = false;
  bool isPlaying = false;
  final recorder = AudioRecorder();
  bool isPause = false; // Indicateur si l'audio est en pause
  bool isLoading = false; // Indicateur de chargement de l'audio

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
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
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: Chat.length,
                itemBuilder: (_, index) {
                  var chat = Chat[Chat.length - (index + 1)];

                  if (chat.kind == 'text') {
                    return BubbleSpecialThree(
                      isSender: chat.sender_name == myName,
                      text: chat.text,
                      color: chat.sender_name == myName
                          ? Colors.green
                          : Colors.black45,
                      tail: true,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    );
                  } else if (chat.kind == 'image') {
                    return BubbleNormalImage(
                      id: chat.image,
                      isSender: chat.sender_name == myName,
                      image: Image.file(File(chat.image)),
                    );
                  } else if (chat.kind == 'audio') {
                    return BubbleNormalAudio(
                      color: chat.sender_name == myName
                          ? Colors.blue
                          : Colors.green,
                      isSender: chat.sender_name == myName,
                      // Utilise la valeur maximale de la durée pour éviter les erreurs
                      duration: chat.duration.inSeconds
                          .toDouble()
                          .clamp(0, double.infinity),
                      // Assure-toi que position ne dépasse pas la durée et est au moins 0
                      position: chat.position.inSeconds
                          .toDouble()
                          .clamp(0, chat.duration.inSeconds.toDouble()),
                      isPlaying: playingAudioId == chat.audio,
                      isLoading: isLoading,
                      isPause: isPause,
                      onSeekChanged: (newPosition) {
                        _changeSeek(newPosition, chat);
                      },
                      onPlayPauseButtonClick: () {
                        _playAudio(chat.audio, chat.audio, chat);
                      },
                      sent: chat.sender_name == myName,
                    );
                  } else {
                    return Container(); // Handle other types if necessary
                  }
                },
              ),
            ),
            _buildInputArea(context)
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(context) {
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
                          startRecording(); // Démarre l'enregistrement
                        } else {
                          stopRecording(); // Arrête l'enregistrement
                        }
                      });
                    },
                    icon: Icon(
                      isRecording
                          ? Icons.stop
                          : Icons.mic, // Alterne entre le micro et l'icône stop
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      setState(() {
                        Chat.add(ChatModel(
                          textController.text.trim(),
                          'Demba',
                          'text',
                          '',
                          '',
                          false,
                        ));
                        textController.clear(); // Efface le champ après envoi
                      });
                    }
                  },
                  icon: const Icon(Icons.send,
                      color: Colors.green), // Affiche l'icône d'envoi
                ),
        ],
      ),
    );
  }

  void _playAudio(String audioPath, String audioId, ChatModel chat) async {
    if (playingAudioId == audioId) {
      if (isPause) {
        await audioPlayer.resume();
        setState(() {
          isPlaying = true;
          isPause = false;
        });
      } else {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
          isPause = true;
        });
      }
    } else {
      if (isPlaying) {
        await audioPlayer.stop();
      }

      setState(() {
        isLoading = true;
        isPause = false;
      });

      await audioPlayer.play(UrlSource(audioPath));
      setState(() {
        isPlaying = true;
        playingAudioId = audioId;
        isLoading = false;
      });

      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() {
          chat.duration = d;
        });
      });
      audioPlayer.onPositionChanged.listen((Duration p) {
        setState(() {
          chat.position = p;
        });
      });
      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
          playingAudioId = null;
          chat.position = const Duration();
        });
      });
    }
  }

  void _changeSeek(double value, ChatModel chat) {
    setState(() {
      audioPlayer.seek(Duration(seconds: value.toInt()));
      chat.position = Duration(seconds: value.toInt());
    });
  }

  Future<void> startRecording() async {
    final location = await getApplicationDocumentsDirectory();
    String fileName = const Uuid().v1();

    recordedAudioPath = '${location.path}/$fileName.m4a';
    if (await recorder.hasPermission()) {
      await recorder.start(const RecordConfig(), path: recordedAudioPath);
      setState(() {
        isRecording = true;
      });
    }
    print('Recording started');
  }

  Future<void> stopRecording() async {
    String? finalPath = await recorder.stop();
    if (finalPath != null) {
      setState(() {
        recordedAudioPath = finalPath;
        isRecording = false;

        Chat.add(ChatModel('', 'Demba', 'audio', '', recordedAudioPath, false));
      });
    }
    print('Recording stopped and saved at: $recordedAudioPath');
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
      setState(() {
        imagePath = image.path;
        Chat.add(ChatModel('', 'Diagana', 'image', imagePath, '', false));
      });
    }
  }

  Future<void> openImageCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imagePath = image.path;
        Chat.add(ChatModel('', 'Demba', 'image', imagePath, '', false));
      });
    }
  }
}
