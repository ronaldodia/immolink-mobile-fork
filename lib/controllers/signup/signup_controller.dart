import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/utils/network_manager.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/phone_register_confirmation_screen.dart';
import 'package:immolink_mobile/views/screens/verify_email_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/fullscreen_loader.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // variables
  // Controllers should be initialized here
  final firstNameEmailController = TextEditingController();
  final lastNameEmailController = TextEditingController();
  final lastNamePhoneController = TextEditingController();
  final firstNamePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordEmailController = TextEditingController();
  final passwordEmailConfirmController = TextEditingController();
  final passwordPhoneController = TextEditingController();
  final passwordPhoneConfirmController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final phoneNumberInput = Rx<PhoneNumber?>(null);

  final  privacyPolicy = true.obs;
  final  phoneprivacyPolicy = true.obs;
  var verificationId = ''.obs;

  // Form keys
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNumberController.dispose();
  }

/// --- SIGNUP Email Firebase
Future<void> signupWithEmailFirebase() async {
  try {
    // Start Loading
    FullscreenLoader.openDialog('We are processing your information..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

    // Check Internet Connectivity
    final isConnected = await NetworkManager.instance.isConnected();
    if(!isConnected) return;

    //Form Validation
    if(!emailFormKey.currentState!.validate()){
      // FullscreenLoader.stopLoading();
      return;
    }
    
    // Privacy Policy Check
    if(!privacyPolicy.value) {
      DLoader.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');

      return;
    }

    // Register user in the Firebase Auth
    final userCredential = await AuthRepository.instance.registerWithEmailFirebase(emailController.text.trim(), passwordEmailController.text.trim());
    final newUser = UserModel(
      id: userCredential.user!.uid,
      fullName: '${firstNameEmailController.text.trim()} ${lastNameEmailController.text.trim()}',
      email: emailController.text.trim(),
    );

    final userRepository = Get.put(UserRepository());
    await  userRepository.saveUserRecord(newUser);

    // save to backend
    final authRepository = Get.put(AuthRepository());
    final backToken = await authRepository.registerWithEmail(
      '${firstNameEmailController.text.trim()} ${lastNameEmailController.text.trim()}',
      emailController.text.trim() ?? '',
      passwordEmailController.text.trim(),
      passwordEmailConfirmController.text.trim(),
      'customer'
    );

    print('======= token created ===========');
    print(backToken);

    //Remove Loader
    FullscreenLoader.stopLoading();

    /// Show Success Message
    DLoader.successSnackBar(title: 'Congratulation', message: 'Your account has been create! verify email to continue.');

    // Get.to(() => const VerifyEmailScreen());

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
    });
  } catch (e) {
    DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
  }
  finally {
        FullscreenLoader.stopLoading();
  }
}

// Fonction pour gérer les changements dans le champ de numéro de téléphone
  void onPhoneNumberChanged(PhoneNumber number) {
    phoneNumberInput.value = number;
  }

  /// --- SIGNUP Phone Firebase

  Future<void> signupWithPhoneFirebase() async {

    try {
      // Start Loading
      print(' ================== ${phoneNumberInput.value!.phoneNumber!.replaceAll('+', '')}==============');
      FullscreenLoader.openDialog('We are processing your information..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;

      //Form Validation
      if(!phoneFormKey.currentState!.validate()){
        // FullscreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if(!phoneprivacyPolicy.value) {
        DLoader.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');

        return;
      }


      // Register user in the Firebase Auth
      await AuthRepository.instance.registerWithPhoneNumber(phoneNumberInput.value!.phoneNumber!);


      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your account has been create! verify email to continue.');



      // Get.to(() => const VerifyEmailScreen());

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(() =>  PhoneRegisterConfirmationScreen(phoneNumber: phoneNumberInput.value!.phoneNumber!,));
      });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    }
    finally {
      FullscreenLoader.stopLoading();
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    try {

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;
      // Start Loading
      // FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
       await AuthRepository.instance.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your account has been verified!');

      final newUser = UserModel(
          id: phoneNumberInput.value!.phoneNumber!,
          fullName: '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
          email: '${phoneNumberController.text.trim()}@gmail.com',
          phone: phoneNumberController.text.trim()
      );

      final userRepository = Get.put(UserRepository());
      await  userRepository.saveUserRecord(newUser);

      // save to backend
      final authRepository = Get.put(AuthRepository());
      final backToken = await authRepository.registerWithPhone(
          '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
          phoneNumberInput.value!.phoneNumber!.replaceAll('+', '') ?? '',
          passwordPhoneController.text.trim(),
          passwordPhoneConfirmController.text.trim(),
          'customer'
      );

      print('======= token created ===========');
      print(backToken);

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAll(() => const BottomNavigationMenu());
      });

      // AuthRepository.instance.screenRedirect();

      // Navigate to the home screen or wherever you want

    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    } finally {
      FullscreenLoader.stopLoading();
    }
  }

  Future<void> loginVerifySmsCode(String smsCode) async {
    try {

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) return;
      // Start Loading
      // FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await AuthRepository.instance.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(title: 'Congratulation', message: 'Your account has been verified!');


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
}