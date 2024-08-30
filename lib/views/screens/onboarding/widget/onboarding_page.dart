import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
class OnBoardingPage extends StatelessWidget {

  const OnBoardingPage({super.key, required this.image, required this.title, required this.subTitle});
  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: Helper.getScreenWidth(context) * 0.8,
            height: Helper.getScreenHeight(context) * 0.6,
            image:  AssetImage(image),
          ),
          Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
          const SizedBox(height: TSizes.spaceBtwItems,),
          Text(subTitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,),

          // const SizedBox(height: TSizes.spaceBtwItems,),
        ],
      ),
    );
  }
}