import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/onboarding/onboarding_controller.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: kToolbarHeight,
        right: TSizes.defaultSpace,
        child: TextButton(
            onPressed: () => OnBoardingController.instance.skipPage(),
            child: const Text('Skip')));
  }
}