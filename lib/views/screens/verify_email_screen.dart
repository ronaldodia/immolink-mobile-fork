import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/signup/verify_email_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/login_email_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put( VerifyEmailController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () =>  AuthRepository.instance.logout(), icon: const Icon(Icons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Image(image: const AssetImage(TImages.emailConfirmImage), width: Helper.getScreenWidth(context) * 0.8,),
              const SizedBox(height: TSizes.spaceBtwSections,),
              /// TITLE
              Text("Verify your email address!", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text(email ?? '', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text("Congratulation Your Account Awaits Verify Your Email to Start Booking and Experiences a world of Unrivaled Deals and Personalized Offers.",
                style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwSections,),

              ///Buttons
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.checkEmailVerificationStatus(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Continue", style: TextStyle(
                      color: Colors.white, fontSize: TSizes.fontSizeSm ),),),),
              const SizedBox(height: TSizes.spaceBtwItems,),
              SizedBox(width: double.infinity,
                child: TextButton(onPressed: () => controller.sendEmailVerification(),

                  child: const Text("Resend Email", style: TextStyle(
                      fontSize: TSizes.fontSizeSm ),),),)

              //Button
              // Text('A verification email has been sent to ${widget.email}. Please check your inbox.'),
              // ElevatedButton(
              //   onPressed: _checkEmailVerified,
              //   child: const Text('I have verified my email'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
