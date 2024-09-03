import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/agencies_screen.dart';
import 'package:immolink_mobile/views/screens/chat_list_screen.dart';
import 'package:immolink_mobile/views/screens/home_content_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/screens/wishlist_screen.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';

class BottomNavigationMenu extends StatelessWidget {
  const BottomNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(
        () =>  NavigationBar(
            height: 80,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedIndex: controller.selectIndex.value,
            onDestinationSelected: (index) => controller.selectIndex.value = index,
            destinations:  [
              NavigationDestination(icon: SvgPicture.asset(TImages.home, colorFilter: const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),), label: 'Home', ),
               NavigationDestination(icon: SvgPicture.asset(TImages.officeSvg, colorFilter: const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),), label: 'Agencies',),
              const NavigationDestination(icon: Icon(Icons.map_rounded, color: Colors.blueGrey,), label: 'Map',),
               NavigationDestination(icon: SvgPicture.asset(TImages.like, colorFilter: const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),), label: 'Wishlist',),
               NavigationDestination(icon: SvgPicture.asset(TImages.inactiveChat, colorFilter: const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),), label: 'Chat',),
            ],
          )
      ),
      body:  Obx(() => controller.screens[controller.selectIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectIndex = 0.obs;


  final screens = [const HomeContentScreen(), const AgenciesScreen(),  const MapScreen(), const WishlistScreen(), const ChatListScreen()];
}
