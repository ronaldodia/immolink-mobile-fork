import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/views/screens/home_content_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';

class BottomNavigationMenu extends StatelessWidget {
  const BottomNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  const DefaultAppBar(),
      bottomNavigationBar: Obx(
        () =>  NavigationBar(
            height: 80,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedIndex: controller.selectIndex.value,
            onDestinationSelected: (index) => controller.selectIndex.value = index,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_filled, color: Colors.blueGrey,), label: 'Home', ),
              NavigationDestination(icon: Icon(Icons.map_rounded, color: Colors.blueGrey,), label: 'Map',),
              NavigationDestination(icon: Icon(Icons.favorite, color: Colors.blueGrey,), label: 'Wishlist',),
              NavigationDestination(icon: Icon(Icons.chat_bubble, color: Colors.blueGrey,), label: 'Chat',),
            ],
          )
      ),
      body:  Obx(() => controller.screens[controller.selectIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectIndex = 0.obs;


  final screens = [const HomeContentScreen(), const MapScreen(), Container(color: Colors.orange,), Container(color: Colors.blue,)];
}
