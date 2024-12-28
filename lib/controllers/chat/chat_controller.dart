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
      final data = await _chatService.getConversations();
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
      // First, check if a conversation already exists for this property
      Conversation? existingConversation;

      try {
        existingConversation = conversations.firstWhere(
              (conv) => conv.propertyId == propertyId,
        );
        return existingConversation;
      } catch (e) {
        // No existing conversation found, continue to create new one
      }

      // If no conversation exists, create a new one
      final response = await _chatService.createConversation(
        participants: [], // Backend will add current user automatically
        propertyId: propertyId,
        title: propertyTitle,
        agentId: agentId,
      );

      final newConversation = Conversation.fromJson(response);
      conversations.add(newConversation);

      return newConversation;
    } catch (e) {
      print('Error in getOrCreateConversation: $e');
      throw Exception('Failed to create conversation');
    }
  }
}