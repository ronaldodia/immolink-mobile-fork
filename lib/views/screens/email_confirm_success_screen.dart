import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:lottie/lottie.dart';

class EmailConfirmSuccessScreen extends StatelessWidget {
  // final String email;
  const EmailConfirmSuccessScreen({super.key, required this.image, required this.title, required this.subTitle, required this.onPressed});
  final String image, title, subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: TSizes.paddingWithAppBarHeight * 1.5,
          child: Column(
            children: [
              Lottie.network(image, width: Helper.getScreenWidth(context) * 0.8, height: Helper.getScreenHeight(context) * 0.6,),
              const SizedBox(height: TSizes.spaceBtwSections,),
              /// TITLE
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              // Text(email, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text(subTitle,
                style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwSections,),


              SizedBox(width: double.infinity,
                child: ElevatedButton(onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Continue", style: TextStyle(
                      color: Colors.white, fontSize: TSizes.fontSizeSm ),),),),
            ],
          ),
        ),
      ),
    );
  }
}
