class Conversation {
  final String id;
  final String title;
  final List<int> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int propertyId;  // Add this field
  final String? propertyImage;
  final String? userImage;

  Conversation({
    required this.id,
    required this.title,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.propertyId,  // Add this
    this.propertyImage,
    this.userImage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'].toString(),
      title: json['title'] ?? '',
      participants: List<int>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      propertyId: json['property'] ?? 0,  // Add this
      propertyImage: json['propertyImage'],
      userImage: json['userImage'],
    );
  }
}