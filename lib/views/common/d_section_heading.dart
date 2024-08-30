import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class DSectionHeading extends StatelessWidget {
  const DSectionHeading({
    super.key, this.textColor,  this.showActionButton = false, required this.title,  this.buttonTitle = 'view all', this.onPressed,
  });

  final Color? textColor;
  final bool showActionButton;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall!.apply(color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis,),
        const SizedBox(width: TSizes.customSpaceBtwSections,),
        if(showActionButton) TextButton(onPressed: onPressed, child:  Text(buttonTitle))

      ],
    );
  }
}