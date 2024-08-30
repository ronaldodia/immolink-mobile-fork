import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/views/screens/email_confirm_success_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class VerifyEmailController extends GetxController {

  static VerifyEmailController get instance => Get.find();


  /// Send Email Whenever Verify Screen appears & Set Timer for auto redirect.
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    checkEmailVerificationStatus();
      super.onInit();
  }

  /// Send Email Verification Link
  sendEmailVerification() async{
    try{
      await AuthRepository.instance.sendEmailVerification();
      DLoader.successSnackBar(title: 'Email Sent', message: 'Please Check you inbox and verify your email');
    }catch(e) {
      DLoader.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }


  /// Timer to automatically redirect on Email Verification
  setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) async{
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user?.emailVerified ?? false){
        timer.cancel();
        Get.off(() =>  EmailConfirmSuccessScreen(
          image: 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json',
          title: 'Your email is successful verified',
          subTitle: "Welcome to your Ultimate Real Estate Destination. Your Account is Created Uni eash the Joy of Seamless Real Estate Sell , Tenant & Booking",
          onPressed: () => AuthRepository.instance.screenRedirect(),
        ));
      }
    });
  }


  /// Manually Check if Email Verified
  checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null && currentUser.emailVerified){
      Get.off(
          () => EmailConfirmSuccessScreen(
            image: 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json',
            title: 'Your email is successful verified',
            subTitle: "Welcome to your Ultimate Real Estate Destination. Your Account is Created Uni eash the Joy of Seamless Real Estate Sell , Tenant & Booking",
            onPressed: () => AuthRepository.instance.screenRedirect(),
          )
      );
    }
  }

}