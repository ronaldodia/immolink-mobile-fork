import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/chat/chat_controller.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
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
              return ListView.builder(
                itemCount: chatController.filteredConversations.length,
                itemBuilder: (context, index) {
                  var conversation = chatController.filteredConversations[index];
                  return ListTile(
                    leading: _buildImageStack(), // Images imbriquées
                    title: Text(conversation.name),
                    subtitle: Text(conversation.lastMessage),
                    trailing: Text(
                      timeAgo(conversation.lastMessageTime), // Fonction pour formater l'heure
                    ),
                    onTap: () {
                      // Naviguer vers l'écran de détails de la conversation
                      Get.to(ChatScreen(conversationId: conversation.id));
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

  // Widget pour afficher les images imbriquées de l'utilisateur et de la propriété
  Widget _buildImageStack() {
    return const Stack(
      children: [
        // Image de la propriété (en arrière-plan)
        CircleAvatar(
          radius: 24, // Taille de l'image de la propriété
          backgroundImage: AssetImage(TImages.featured1), // Chemin de l'image de la propriété
        ),
        // Image de l'utilisateur (superposée en bas à droite)
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 12, // Taille de l'image de l'utilisateur
            backgroundColor: Colors.white, // Fond blanc pour bien voir le contour
            child: CircleAvatar(
              radius: 10, // Taille de l'image interne de l'utilisateur
              backgroundImage: AssetImage('assets/images/avatar.jpg'), // Chemin de l'image de l'utilisateur
            ),
          ),
        ),
      ],
    );
  }

  // Fonction pour formater le temps en 'x min', 'x h', ou 'x j'
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
