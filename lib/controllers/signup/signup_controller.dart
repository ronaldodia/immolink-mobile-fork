import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/utils/network_manager.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/views/screens/phone_register_confirmation_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/fullscreen_loader.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // variables
  final NetworkManager _networkManager = Get.put(NetworkManager());
  final AuthRepository _authRepository = Get.put(AuthRepository());
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
    // Nettoyer tous les contrôleurs de texte
    firstNameEmailController.dispose();
    lastNameEmailController.dispose();
    lastNamePhoneController.dispose();
    firstNamePhoneController.dispose();
    emailController.dispose();
    passwordEmailController.dispose();
    passwordEmailConfirmController.dispose();
    passwordPhoneController.dispose();
    passwordPhoneConfirmController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  /// Réinitialise le formulaire et nettoie les données
  void resetForm() {
    firstNamePhoneController.clear();
    lastNamePhoneController.clear();
    phoneNumberController.clear();
    passwordPhoneController.clear();
    passwordPhoneConfirmController.clear();
    // Ne pas réinitialiser le numéro de téléphone car il est nécessaire pour la vérification
    // phoneNumber.value = '';
    phoneprivacyPolicy.value = true;
  }

  /// Réinitialise complètement le formulaire (appelé après une inscription réussie)
  void resetFormComplete() {
    firstNamePhoneController.clear();
    lastNamePhoneController.clear();
    phoneNumberController.clear();
    passwordPhoneController.clear();
    passwordPhoneConfirmController.clear();
    // Ne pas effacer le numéro de téléphone car il est nécessaire pour la vérification
    // phoneNumber.value = '';
    phoneprivacyPolicy.value = true;
  }

  /// Réinitialise complètement le formulaire après une inscription réussie
  void resetFormAfterSuccess() {
    firstNamePhoneController.clear();
    lastNamePhoneController.clear();
    phoneNumberController.clear();
    passwordPhoneController.clear();
    passwordPhoneConfirmController.clear();
    phoneNumber.value = '';
    phoneprivacyPolicy.value = true;
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
      final fullNumber = countryCode.value!.dialCode! + number.trim();
      print('Setting full phone number to: $fullNumber');
      phoneNumber.value = fullNumber;
    } else {
      print('Warning: Country code is null, using default +222');
      // Utiliser le code pays par défaut si null
      final fullNumber = '+222' + number.trim();
      print('Setting full phone number with default code: $fullNumber');
      phoneNumber.value = fullNumber;
    }

    print('Final phone number value: ${phoneNumber.value}');
  }

  /// Valide le format du numéro de téléphone
  bool validatePhoneNumber(String phoneNumber) {
    // Supprimer tous les caractères non numériques sauf le +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Vérifier que le numéro commence par + et a au moins 8 chiffres après
    if (!cleanNumber.startsWith('+') || cleanNumber.length < 9) {
      return false;
    }

    // Vérifier que le reste du numéro ne contient que des chiffres
    final numberWithoutPlus = cleanNumber.substring(1);
    if (!RegExp(r'^\d+$').hasMatch(numberWithoutPlus)) {
      return false;
    }

    return true;
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
              countryCode.value!.dialCode! + phoneNumberController.text.trim();
          print('Constructing phone number: $fullNumber');
          phoneNumber.value = fullNumber;
        } else {
          // Utiliser le code pays par défaut si nécessaire
          final fullNumber = '+222' + phoneNumberController.text.trim();
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
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) {
        FullscreenLoader.stopLoading();
        DLoader.errorSnackBar(
            title: 'Erreur de connexion',
            message: 'Veuillez vérifier votre connexion internet');
        return;
      }

      // Vérifier si l'utilisateur existe déjà
      try {
        final userExists =
            await _authRepository.checkUserExists(phoneNumber.value);
        if (userExists) {
          FullscreenLoader.stopLoading();
          DLoader.errorSnackBar(
              title: 'Erreur',
              message: 'Un compte existe déjà avec ce numéro de téléphone');
          return;
        }
      } catch (e) {
        print('Error checking user existence: $e');
        // Continue with registration even if check fails
      }

      //Form Validation
      if (!validatePhoneNumber(phoneNumber.value)) {
        FullscreenLoader.stopLoading();
        DLoader.errorSnackBar(
            title: 'Erreur',
            message: 'Veuillez entrer un numéro de téléphone valide');
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

      print('All validations passed, proceeding with Firebase registration...');

      // Register user in the Firebase Auth
      await _authRepository.registerWithPhoneNumber(phoneNumber.value);

      print('Firebase registration completed successfully');

      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(
          title: 'Félicitations',
          message:
              'Votre compte a été créé ! Veuillez vérifier votre numéro de téléphone.');

      // Navigate to confirmation screen
      Get.off(() => PhoneRegisterConfirmationScreen(
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
      // Start Loading
      FullscreenLoader.openDialog('Vérification du code SMS...',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      print('Starting SMS verification process...');
      print('SMS Code: $smsCode');
      print('Current phoneNumber.value: ${phoneNumber.value}');
      print(
          'Current phoneNumberController.text: ${phoneNumberController.text}');
      print('Current countryCode.value: ${countryCode.value?.dialCode}');

      // S'assurer que le numéro de téléphone est correctement défini
      if (phoneNumber.value.isEmpty) {
        print('Phone number is empty, attempting to reconstruct...');
        if (countryCode.value != null &&
            phoneNumberController.text.isNotEmpty) {
          final fullNumber =
              countryCode.value!.dialCode! + phoneNumberController.text.trim();
          print('Constructing phone number from controller: $fullNumber');
          phoneNumber.value = fullNumber;
        } else {
          print('ERROR: Phone number is empty and cannot be constructed');
          print('countryCode.value: ${countryCode.value?.dialCode}');
          print('phoneNumberController.text: "${phoneNumberController.text}"');

          // Essayer de récupérer le numéro depuis le localStorage ou d'autres sources
          // Pour l'instant, afficher un message d'erreur plus informatif
          DLoader.errorSnackBar(
              title: 'Erreur',
              message:
                  'Numéro de téléphone manquant. Veuillez redémarrer le processus d\'inscription.');
          return;
        }
      }

      print('Final Phone Number for verification: ${phoneNumber.value}');

      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) {
        DLoader.errorSnackBar(
            title: 'Erreur de connexion',
            message: 'Veuillez vérifier votre connexion internet');
        return;
      }

      print(
          'Internet connection verified, proceeding with SMS verification...');

      // Verify the SMS code
      try {
        await _authRepository.signInWithSmsCode(smsCode);
        print('SMS verification successful, proceeding with user creation...');
      } catch (smsError) {
        print('SMS verification failed: $smsError');
        throw smsError;
      }

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(
          title: 'Félicitations',
          message: 'Votre compte a été créé avec succès !');

      // Start Loading for account creation
      FullscreenLoader.openDialog('Création de votre compte...',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      final newUser = UserModel(
          id: phoneNumber.value!,
          fullName:
              '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
          email: '${phoneNumberController.text.trim()}@gmail.com',
          phone: phoneNumber.value!);

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      print(
          'User record saved locally, proceeding with backend registration...');

      // save to backend
      try {
        final backToken = await _authRepository.registerWithPhone(
            '${firstNamePhoneController.text.trim()} ${lastNamePhoneController.text.trim()}',
            phoneNumber.value ?? '',
            passwordPhoneController.text.trim(),
            passwordPhoneConfirmController.text.trim(),
            'customer');

        print('======= token created ===========');
        print(backToken);

        // Stop loading before navigation
        FullscreenLoader.stopLoading();

        // Rediriger vers la page de connexion
        Get.offAll(() => const LoginPhoneScreen());
      } catch (backendError) {
        print('Backend registration failed: $backendError');

        // Déconnecter de Firebase si la connexion au backend échoue
        try {
          await _authRepository.logout();
          print('Firebase logout successful after backend failure');
        } catch (firebaseLogoutError) {
          print('Firebase logout error: $firebaseLogoutError');
        }

        FullscreenLoader.stopLoading();
        DLoader.errorSnackBar(
            title: 'Erreur de connexion au serveur',
            message:
                'Impossible de créer votre compte. Veuillez réessayer plus tard.');

        // Rediriger vers la page de connexion
        Get.offAll(() => const LoginPhoneScreen());
      }

      // Réinitialiser le formulaire seulement après une inscription réussie
      resetFormAfterSuccess();
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during SMS verification: ${e.code} - ${e.message}');
      FullscreenLoader.stopLoading();

      String errorMessage = 'Erreur de vérification du code SMS';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Code SMS incorrect. Veuillez réessayer.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'Session expirée. Veuillez demander un nouveau code.';
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            'Trop de tentatives. Veuillez attendre avant de réessayer.';
      } else if (e.code == 'invalid-verification-id') {
        errorMessage =
            'Session de vérification invalide. Veuillez redémarrer le processus.';
      }

      DLoader.errorSnackBar(title: 'Erreur', message: errorMessage);
      // Ne pas réinitialiser le formulaire en cas d'erreur de code SMS
      // resetFormComplete();
    } catch (e) {
      print('Error during SMS verification: $e');
      print('Error type: ${e.runtimeType}');
      FullscreenLoader.stopLoading();

      String errorMessage = 'Une erreur est survenue lors de la vérification';
      if (e.toString().contains('Verification ID is missing')) {
        errorMessage =
            'Erreur de session. Veuillez redémarrer le processus d\'inscription.';
      } else if (e.toString().contains('Something went wrong')) {
        errorMessage =
            'Erreur de connexion avec Firebase. Veuillez vérifier votre connexion et réessayer.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Erreur de réseau. Veuillez vérifier votre connexion internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Veuillez réessayer.';
      }

      DLoader.errorSnackBar(title: 'Erreur', message: errorMessage);
      // Ne pas réinitialiser le formulaire en cas d'erreur
      // resetFormComplete();
    }
  }

  Future<void> loginVerifySmsCode(String smsCode) async {
    try {
      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) return;
      // Start Loading
      // FullscreenLoader.openDialog('Verifying code..', 'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await _authRepository.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your account has been verified!');

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAll(() => const HomeScreen());
      });

      // Navigate to the home screen or wherever you want
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    } finally {
      FullscreenLoader.stopLoading();
    }
  }
}
