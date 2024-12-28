import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/chat/chat_controller.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/models/Conversation.dart';
import 'package:immolink_mobile/views/screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());

  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                chatController.searchQuery.value = value;
              },
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Liste des conversations
          Expanded(
            child: Obx(() {
              if (chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: chatController.filteredConversations.length,
                itemBuilder: (context, index) {
                  var conversation = chatController.filteredConversations[index];
                  return ListTile(
                    leading: _buildImageStack(conversation),
                    title: Text(conversation.title),
                    subtitle: Text(conversation.lastMessage),
                    trailing: Text(
                      timeAgo(conversation.lastMessageTime),
                    ),
                    onTap: () {
                      Get.to(() => ChatScreen(conversationId: conversation.id,));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStack(Conversation conversation) {
    return Stack(
      children: [
        // Image de la propriété (en arrière-plan)
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            conversation.propertyImage ?? TImages.featured1,
          ),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback image in case of error
            const AssetImage(TImages.featured1);
          },
        ),
        // Image de l'utilisateur (superposée en bas à droite)
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage(
                conversation.userImage ?? 'assets/images/avatar.jpg',
              ),
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback image in case of error
                const AssetImage('assets/images/avatar.jpg');
              },
            ),
          ),
        ),
      ],
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else {
      return '${difference.inDays} j';
    }
  }
}