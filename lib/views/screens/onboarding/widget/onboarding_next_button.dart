import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/onboarding/onboarding_controller.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: TSizes.defaultSpace,
        bottom: kBottomNavigationBarHeight,
        child: ElevatedButton(
          onPressed: () => OnBoardingController.instance.nextPage(),
          style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: Colors.black),
          child: const Icon(Icons.arrow_right, color: Colors.green,),
        ));
  }
}