class Conversation {
  final String id;
  final String title;
  final List<int> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int propertyId;
  final String? propertyImage;
  final String? userImage;

  Conversation({
    required this.id,
    required this.title,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.propertyId,
    this.propertyImage,
    this.userImage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // DEBUG: Imprimer la réponse JSON pour voir les valeurs exactes
    print('Conversation.fromJson - JSON reçu: $json');

    return Conversation(

      id: (json['_id'] ?? json['id'] ?? '').toString(),


      title: json['title']?.toString() ?? 'Conversation',

      participants: _parseParticipants(json['participants']),


      lastMessage: json['lastMessage']?.toString() ?? 'Aucun message',


      lastMessageTime: _parseDateTime(json['updatedAt'] ?? json['createdAt']),


      propertyId: _parsePropertyId(json['property'] ?? json['propertyId']),

      propertyImage: json['propertyImage']?.toString(),
      userImage: json['userImage']?.toString(),
    );
  }

  // Méthodes helper pour un parsing robuste
  static List<int> _parseParticipants(dynamic participantsData) {
    if (participantsData == null) return [];

    if (participantsData is List) {
      return participantsData
          .where((item) => item != null)
          .map((item) => int.tryParse(item.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    return [];
  }

  static DateTime _parseDateTime(dynamic dateData) {
    if (dateData == null) return DateTime.now();

    try {
      if (dateData is String) {
        return DateTime.parse(dateData);      }
      return DateTime.now();
    } catch (e) {
      print('Erreur parsing DateTime: $e');
      return DateTime.now();
    }
  }

  static int _parsePropertyId(dynamic propertyData) {
    if (propertyData == null) return 0;

    try {
      return int.parse(propertyData.toString());
    } catch (e) {
      print('Erreur parsing propertyId: $e, valeur: $propertyData');
      return 0;
    }
  }

  @override
  String toString() {
    return 'Conversation{id: $id, title: $title, participants: $participants, '
        'lastMessage: $lastMessage, propertyId: $propertyId}';
  }
}