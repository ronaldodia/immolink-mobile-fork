import 'package:get/get.dart';
import 'package:immolink_mobile/services/chat_service.dart';
import 'package:immolink_mobile/models/Conversation.dart';class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  RxList<Conversation> conversations = <Conversation>[].obs;
  RxString searchQuery = ''.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      final data = await   _chatService.getConversations();
      conversations.value = data.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      print('Error loading conversations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Conversation> get filteredConversations => conversations.where((conv) {
    return conv.title.toLowerCase().contains(searchQuery.value.toLowerCase());
  }).toList();
  Future<Conversation> getOrCreateConversation({
    required int propertyId,
    required String propertyTitle,
    required int agentId,
  }) async {
    try {
      // Validation des paramètres
      if (propertyId <= 0) {
        throw Exception('ID de propriété invalide: $propertyId');
      }

      if (agentId <= 0) {
        throw Exception('ID d\'agent invalide: $agentId');
      }

      if (propertyTitle.isEmpty) {
        throw Exception('Titre de propriété vide');
      }

      print('Création/récupération de conversation - PropertyId: $propertyId, AgentId: $agentId, Title: $propertyTitle');

      // Recherche d'une conversation existante
      Conversation? existingConversation;
      try {
        existingConversation = conversations.firstWhere(
              (conv) => conv.propertyId == propertyId,
        );
        print('Conversation existante trouvée: ${existingConversation.id}');
        return existingConversation;
      } catch (e) {
        print('Aucune conversation existante trouvée, création d\'une nouvelle...');
      }

      // Création d'une nouvelle conversation
      final response = await _chatService.createConversation(
        participants: [], // Backend ajoute automatiquement l'utilisateur actuel
        propertyId: propertyId,
        title: propertyTitle,
        agentId: agentId,
      );

      final newConversation = Conversation.fromJson(response);
      conversations.add(newConversation);
      print('Nouvelle conversation créée: ${newConversation.id}');

      return newConversation;
    } catch (e) {
      print('Erreur détaillée dans getOrCreateConversation: $e');
      print('PropertyId: $propertyId, AgentId: $agentId, Title: $propertyTitle');
      throw Exception('Échec de création de conversation: ${e.toString()}');
    }
  }

}