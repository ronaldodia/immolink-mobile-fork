import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/onboarding/onboarding_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/onboarding/widget/onboarding_dot_navigation.dart';
import 'package:immolink_mobile/views/screens/onboarding/widget/onboarding_next_button.dart';
import 'package:immolink_mobile/views/screens/onboarding/widget/onboarding_page.dart';
import 'package:immolink_mobile/views/screens/onboarding/widget/onboarding_skip.dart';

class OnBoardingScreen extends StatelessWidget {

  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Horizontal scroll pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(image: TImages.docerAnimation,title:  'Choose you Add',subTitle:  Config.appLoginSubTitle),
              OnBoardingPage(image: TImages.emailConfirmImage,title:  'Choose you Add',subTitle:  Config.appLoginSubTitle),
              OnBoardingPage(image: TImages.emailConfirmImage,title:  'Choose you Add',subTitle:  Config.appLoginSubTitle),
            ],
          ),

          // Skip button
          const OnBoardingSkip(),

          //Dot Navigation SmoothPageIndicator
            const OnBoardingDotNavigation(),

          //Circular Button
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}


