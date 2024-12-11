import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/user/user_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/network_manager.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/login_screen.dart';
import 'package:immolink_mobile/views/screens/phone_login_confirmation_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/fullscreen_loader.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class LoginController extends GetxController{
  //variables
  final emailRememberMe = false.obs;
  final hideEmailPassword = true.obs;
  final phoneRememberMe = false.obs;
  final hidePhonePassword = true.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final emailPasswordController = TextEditingController();
  final phonePasswordController = TextEditingController();
  final localStorage = GetStorage();
  GlobalKey<FormState> emailLoginFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneLoginFormKey = GlobalKey<FormState>();

  final userController = Get.put(UserController());


  @override
  void onInit() {
    // emailController.text = localStorage.read('REMEMBER_ME_EMAIL');
    // emailPasswordController.text = localStorage.read('REMEMBER_ME_EMAIL_PASSWORD');
    // phonePasswordController.text = localStorage.read('REMEMBER_ME_PHONE_PASSWORD');
    super.onInit();
  }

  Future<void> loginWithEmailPassword() async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logging you in..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;

      //Form Validation
      if(!emailLoginFormKey.currentState!.validate()){
        // FullscreenLoader.stopLoading();
        return;
      }


      if(emailRememberMe.value){
        localStorage.write('REMEMBER_ME_EMAIL', emailController.text.trim());
        localStorage.write('REMEMBER_ME_EMAIL_PASSWORD', emailPasswordController.text.trim());
      }



      // login with backend
      final resultByEmail = await AuthRepository.instance.loginWithEmail(emailController.text.trim(), emailPasswordController.text.trim());
      if (resultByEmail != null && resultByEmail != "error credentials" && resultByEmail != "Unauthenticated") {
        // Résultat valide : On écrit dans le localStorage
        localStorage.write('AUTH_TOKEN', resultByEmail);
      } else {
        // Résultat invalide ou erreur : Afficher un message d'erreur approprié
        DLoader.errorSnackBar(title: 'OH Snap!', message: resultByEmail);
      }

      // Register user in the Firebase Auth
      // final userCredential = await AuthRepository.instance.loginWithEmailFirebase(emailController.text.trim(), emailPasswordController.text.trim());


      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your successfuly loggin in.');
      localStorage.write('AUTH_TOKEN', resultByEmail);
      AuthRepository.instance.screenRedirect();

      // Future.delayed(const Duration(milliseconds: 100), () {
      //   Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
      // });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: 'Erreur de saisie');
    }
    finally {
      FullscreenLoader.stopLoading();
    }
  }

  // login with phone number
  Future<void> loginWithPhonePassword() async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logging you in..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;

      //Form Validation
      if(!phoneLoginFormKey.currentState!.validate()){
        // FullscreenLoader.stopLoading();
        return;
      }


      if(emailRememberMe.value){
        localStorage.write('REMEMBER_ME_PHONE', phoneController.text.trim());
        localStorage.write('REMEMBER_ME_PHONE_PASSWORD', phonePasswordController.text.trim());
      }



      // login with backend
      final resultByPhone = await AuthRepository.instance.loginWithPhone(phoneController.text.trim(), phonePasswordController.text.trim());
      if (resultByPhone != null && resultByPhone != "error credentials" && resultByPhone != "Unauthenticated") {
        // Résultat valide : On écrit dans le localStorage
        localStorage.write('AUTH_TOKEN', resultByPhone);
      } else {
        // Résultat invalide ou erreur : Afficher un message d'erreur approprié
        DLoader.errorSnackBar(title: 'OH Snap!', message: resultByPhone);
      }


    // Login user in the Firebase Auth
    await AuthRepository.instance.loginWithPhoneNumber('+${phoneController.text.trim()}');

      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your successfuly loggin in.');
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(() =>  PhoneLoginConfirmationScreen(phoneNumber: '+${phoneController.text.trim()}',));
      });

      // Future.delayed(const Duration(milliseconds: 100), () {
      //   Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
      // });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    }
    finally {
      FullscreenLoader.stopLoading();
    }
  }




  // -- Google SignIn Authentication
  Future<void> googleSign() async {
    try{
      // Start Loading...
      FullscreenLoader.openDialog('Logging you in..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        FullscreenLoader.stopLoading();
        return;
      }

      // google Authentication
      final userCredentials = await AuthRepository.instance.signInWithGoogle();

      // Save User Record
      await userController.saveUserRecord(userCredentials);

      FullscreenLoader.stopLoading();

      AuthRepository.instance.screenRedirect();
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your are login in');
    }catch(e) {
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // -- Facebbok SignIn Authentication
  Future<void> facebookSign() async {
    try{
      // Start Loading...
      FullscreenLoader.openDialog('Logging you in..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        FullscreenLoader.stopLoading();
        return;
      }

      // google Authentication
      final userCredentials = await AuthRepository.instance.signInWithFacebook();

      // Save User Record
      await userController.saveUserRecord(userCredentials);

      FullscreenLoader.stopLoading();

      // AuthRepository.instance.screenRedirect();
        Get.to(() =>  const BottomNavigationMenu());

      DLoader.successSnackBar(title: 'Congratulation', message: 'Your are login in');
    }catch(e) {
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    try {

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;
      // Start Loading
      FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await AuthRepository.instance.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your account has been verified!');

      // AuthRepository.instance.screenRedirect();

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAll(() => const BottomNavigationMenu());
      });

      // Navigate to the home screen or wherever you want

    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    } finally {
      FullscreenLoader.stopLoading();
    }
  }

  Future<void> logout() async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logout you in..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;



      if(emailRememberMe.value){
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_EMAIL_PASSWORD');
      }



      // login with backend
      await AuthRepository.instance.logOutBackend(localStorage.read('AUTH_TOKEN'));
      localStorage.remove('AUTH_TOKEN');





      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your successfuly loggin in.');

      AuthRepository.instance.screenRedirect();

      // Future.delayed(const Duration(milliseconds: 100), () {
      //   Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
      // });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    }
    finally {
      FullscreenLoader.stopLoading();
    }
  }

}