import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:lottie/lottie.dart';

class AnimationLoader extends StatelessWidget {
  const AnimationLoader({super.key, required this.text, required this.animation,  this.showAction = false, this.actionText, this.onActionPressed});

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(animation, width: Helper.getScreenWidth(context) * 0.8, height: Helper.getScreenHeight(context) * 0.6,),
          const SizedBox(height: TSizes.defaultSpace,),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.defaultSpace,),
          showAction ? SizedBox(
            width: 250,
            child: OutlinedButton(onPressed: onActionPressed, child: Text(actionText!, style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.lightBlue),)),
          ) : const SizedBox()
        ],
      ),
    );
  }
}
