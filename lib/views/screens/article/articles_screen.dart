import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/article/create_article_screen.dart';
import 'package:immolink_mobile/views/screens/login_screen.dart';

import '../../common/d_search_bar_widget.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckAuthController authController = Get.find();
    return   Scaffold(
      backgroundColor: Colors.white,
      body: const SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
            text: 'Rechercher...',
          )

            //
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bool isAuthenticated = await authController.checkUserToken();
            print(isAuthenticated);
            if (isAuthenticated) {
              // L'utilisateur est authentifié, continuer l'action
              Get.to(() => const CreateArticleScreen());
            }else {

              Get.to(() => const LoginScreen());
            }

          },
          backgroundColor: Colors.teal, // Ajustez la couleur et l'opacité ici
          child: SvgPicture.asset(
            TImages.add,
            colorFilter: const ColorFilter.mode(
                Colors.white, BlendMode.srcIn),
          ),
        )
    );
  }
}
