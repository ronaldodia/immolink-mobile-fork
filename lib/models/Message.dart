import 'package:immolink_mobile/utils/config.dart';

class ChatModel {
  final String id;
  final String text;
  final String sender_name;
  final int sender_id;
  final String kind;
  final String image;
  final String audio;
  Duration duration;
  Duration position;

  ChatModel(
      this.text,
      this.sender_name,
      this.sender_id,
      this.kind,
      this.image,
      this.audio, {
        this.id = '',
        this.duration = const Duration(),
        this.position = const Duration(),
      });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    String mediaFullPath = "https://${Config.chatHostApi}${json['mediaPath']}";

    return ChatModel(
      json['content'] ?? '',           // text content
      json['sender_name'] ?? json['sender'],
      json['sender'] ?? 0,// sender ID (since sender name isn't in the response)
      json['type'] ?? 'text',          // default to text type
      mediaFullPath ?? '',             // image path
      mediaFullPath ?? '',             // audio path
      id: json['_id'] ?? json['id'] ?? '',  // handle both _id and id fields
      duration: Duration(seconds: json['duration'] ?? 0), // set duration from JSON
      position: Duration(seconds: json['position'] ?? 0),   // set position from JSON
    );
  }
}