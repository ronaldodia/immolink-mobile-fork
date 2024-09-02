import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key, required this.text, this.icon = Icons.search,  this.showBackground = true,  this.showBorder = true, this.secondIcon = Icons.tune,
  });

  final String text;
  final IconData? icon, secondIcon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Container(
        width: Helper.getScreenWidth(context),
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
            color: showBackground ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: Colors.grey) : null
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(

              children: [
                Icon(icon, color: Colors.grey,),
                const SizedBox(height: TSizes.spaceBtwSections,),
                Text(text, style: Theme.of(context).textTheme.bodySmall,),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
            Icon(secondIcon, color: Colors.grey,),
          ],
        ),
      ),
    );
  }
}