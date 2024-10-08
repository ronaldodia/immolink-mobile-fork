import 'package:get/get.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}


class ChatController extends GetxController {
  // Liste initiale des conversations
  var conversations = <Conversation>[].obs;
  // Liste filtrée selon la recherche
  var filteredConversations = <Conversation>[].obs;

  // Variable de recherche
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Charger les conversations à l'initialisation
    loadConversations();

    // Mettre à jour la liste filtrée selon la recherche
    ever(searchQuery, (_) => filterConversations());
  }

  // Fonction pour charger les conversations (à remplacer par la logique réelle)
  void loadConversations() {
    // Exemple de conversations
    var loadedConversations = [
      Conversation(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Salut, comment ça va ?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Conversation(
        id: '2',
        name: 'Jane Smith',
        lastMessage: 'On se voit demain !',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];

    conversations.assignAll(loadedConversations);
    filteredConversations.assignAll(loadedConversations);
  }

  // Fonction pour filtrer les conversations selon la recherche
  void filterConversations() {
    if (searchQuery.value.isEmpty) {
      filteredConversations.assignAll(conversations);
    } else {
      var query = searchQuery.value.toLowerCase();
      filteredConversations.assignAll(
        conversations.where((conversation) =>
            conversation.name.toLowerCase().contains(query)
        ).toList(),
      );
    }
  }
}
