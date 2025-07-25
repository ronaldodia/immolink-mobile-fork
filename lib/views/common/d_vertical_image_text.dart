import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class DVerticalImageText extends StatelessWidget {
  const DVerticalImageText({
    super.key, required this.image, required this.title, required this.textColor, this.backgroundColor, this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            /// Circular Icon
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(100)
              ),
              child:  Center(
                child: Image(image: AssetImage(image), fit: BoxFit.cover,),
              ),
            ),
            /// Text
            const SizedBox(height: TSizes.spaceBtwItems / 2,),
            SizedBox(
                width: 55,
                child: Text(title,
                  style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
            )
          ],
        ),
      ),
    );
  }
}