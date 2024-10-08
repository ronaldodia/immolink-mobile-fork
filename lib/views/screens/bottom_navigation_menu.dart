import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Authentication
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/agencies_screen.dart';
import 'package:immolink_mobile/views/screens/chat_list_screen.dart';
import 'package:immolink_mobile/views/screens/home_content_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/screens/wishlist_screen.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';
import 'package:immolink_mobile/views/screens/login_screen.dart'; // Import LoginScreen

class BottomNavigationMenu extends StatelessWidget {
  const BottomNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: const DefaultAppBar(),
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 80,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: controller.selectIndex.value,
          onDestinationSelected: controller.onDestinationSelected, // Utilisation du contrôleur pour la sélection
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.home,
                colorFilter: const ColorFilter.mode(
                    Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.officeSvg,
                colorFilter: const ColorFilter.mode(
                    Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Agencies',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.map_rounded,
                color: Colors.blueGrey,
              ),
              label: 'Map',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.like,
                colorFilter: const ColorFilter.mode(
                    Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.inactiveChat,
                colorFilter: const ColorFilter.mode(
                    Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectIndex = 0.obs;

  // Screens associées au menu de navigation
  final screens = [
    const HomeContentScreen(),
    const AgenciesScreen(),
    const MapScreen(),
    const WishlistScreen(),
     ChatListScreen(),
  ];

  // Méthode pour vérifier l'état de connexion
  Future<void> checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;  // Vérifie si l'utilisateur est connecté
    if (user == null) {
      // Si l'utilisateur n'est pas connecté, rediriger vers la page de connexion
      Get.to(() => const LoginScreen());
    } else {
      // Si l'utilisateur est connecté, rediriger vers la page de chat
      selectIndex.value = 4;  // Met à jour l'index pour afficher la page Chat
    }
  }

  // Gérer la sélection des onglets
  void onDestinationSelected(int index) {
    if (index == 4) {
      // Si l'onglet 'Chat' est sélectionné, vérifie l'état de connexion
      checkLoginStatus();
    } else {
      // Pour les autres onglets, mettre à jour l'index normalement
      selectIndex.value = index;
    }
  }
}
