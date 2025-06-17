import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/utils/network_manager.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/views/screens/phone_register_confirmation_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/fullscreen_loader.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

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
  final phoneNumber = ''.obs;
  final countryCode = Rxn<CountryCode>();

  final privacyPolicy = true.obs;
  final phoneprivacyPolicy = true.obs;
  var verificationId = ''.obs;

  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Initialiser le code pays par défaut (Mauritanie)
    countryCode.value = CountryCode(
      name: 'Mauritania',
      code: 'MR',
      dialCode: '+222',
    );
    print('Initialized country code: ${countryCode.value?.dialCode}');
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  void onCountryChanged(CountryCode code) {
    print('Country code changed to: ${code.dialCode}');
    countryCode.value = code;
    // Mettre à jour le numéro de téléphone si un numéro existe déjà
    if (phoneNumberController.text.isNotEmpty) {
      updatePhoneNumber(phoneNumberController.text);
    }
  }

  void updatePhoneNumber(String number) {
    print('Updating phone number with: $number');
    print('Current country code: ${countryCode.value?.dialCode}');

    if (countryCode.value != null) {
      final fullNumber = countryCode.value!.dialCode! + number;
      print('Setting full phone number to: $fullNumber');
      phoneNumber.value = fullNumber;
    } else {
      print('Warning: Country code is null, using default +222');
      // Utiliser le code pays par défaut si null
      final fullNumber = '+222' + number;
      print('Setting full phone number with default code: $fullNumber');
      phoneNumber.value = fullNumber;
    }
  }

  /// --- SIGNUP Phone Firebase
  Future<void> signupWithPhoneFirebase() async {
    try {
      // Start Loading
      print('Starting signup with phone number: ${phoneNumber.value}');
      print('Country code: ${countryCode.value?.dialCode}');
      print('Phone controller text: ${phoneNumberController.text}');

      // S'assurer que nous avons un numéro de téléphone valide
      if (phoneNumber.value.isEmpty) {
        if (countryCode.value != null &&
            phoneNumberController.text.isNotEmpty) {
          final fullNumber =
              countryCode.value!.dialCode! + phoneNumberController.text;
          print('Constructing phone number: $fullNumber');
          phoneNumber.value = fullNumber;
        } else {
          // Utiliser le code pays par défaut si nécessaire
          final fullNumber = '+222' + phoneNumberController.text;
          print('Constructing phone number with default code: $fullNumber');
          phoneNumber.value = fullNumber;
        }
      }

      if (phoneNumber.value.isEmpty) {
        DLoader.errorSnackBar(
            title: 'Erreur',
            message: 'Veuillez entrer un numéro de téléphone valide');
        return;
      }

      print('Using phone number for registration: ${phoneNumber.value}');
      FullscreenLoader.openDialog('We are processing your information..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullscreenLoader.stopLoading();
        return;
      }

      //Form Validation
      if (!phoneFormKey.currentState!.validate()) {
        FullscreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if (!phoneprivacyPolicy.value) {
        FullscreenLoader.stopLoading();
        DLoader.warningSnackBar(
            title: 'Accept Privacy Policy',
            message:
                'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');
        return;
      }

      // Register user in the Firebase Auth
      await AuthRepository.instance.registerWithPhoneNumber(phoneNumber.value);

      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(
          title: 'Félicitations',
          message:
              'Votre compte a été créé ! Veuillez vérifier votre numéro de téléphone.');

      // Navigate to confirmation screen
      Get.to(() => PhoneRegisterConfirmationScreen(
            phoneNumber: phoneNumber.value,
          ));
    } catch (e, stack) {
      print('Error during phone registration: $e');
      print('Stack trace: $stack');
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(
          title: 'Erreur',
          message:
              'Une erreur est survenue lors de l\'inscription. Veuillez réessayer.');
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    try {
      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;
      // Start Loading
      // FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await AuthRepository.instance.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(
          title: 'Félicitations',
          message: 'Votre compte a été créé avec succès !');

      final newUser = UserModel(
          id: phoneNumber.value!,
          fullName:
              '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
          email: '${phoneNumberController.text.trim()}@gmail.com',
          phone: phoneNumber.value!);

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // save to backend
      final authRepository = Get.put(AuthRepository());
      final backToken = await authRepository.registerWithPhone(
          '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
          phoneNumber.value ?? '',
          passwordPhoneController.text.trim(),
          passwordPhoneConfirmController.text.trim(),
          'customer');

      print('======= token created ===========');
      print(backToken);

      // Rediriger vers la page de connexion
      Future.delayed(const Duration(milliseconds: 100), () {
        // Nettoyer les contrôleurs avant la navigation
        firstNamePhoneController.clear();
        lastNamePhoneController.clear();
        phoneNumberController.clear();
        passwordPhoneController.clear();
        passwordPhoneConfirmController.clear();

        // Naviguer vers l'écran de connexion
        Get.offAll(() => const LoginPhoneScreen());
      });
    } catch (e) {
      DLoader.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      FullscreenLoader.stopLoading();
    }
  }

  Future<void> loginVerifySmsCode(String smsCode) async {
    try {
      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;
      // Start Loading
      // FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await AuthRepository.instance.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your account has been verified!');

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
