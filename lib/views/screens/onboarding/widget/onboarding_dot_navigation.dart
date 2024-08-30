import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/onboarding/onboarding_controller.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
        bottom: kBottomNavigationBarHeight + 25,
        left: TSizes.defaultSpace,

        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 3,
          effect: const ExpandingDotsEffect(activeDotColor: Colors.black, dotHeight: 6),
        ));
  }
}

