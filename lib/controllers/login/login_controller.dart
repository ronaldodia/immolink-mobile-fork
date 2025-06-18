import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/user/user_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/network_manager.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/phone_login_confirmation_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/fullscreen_loader.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:immolink_mobile/models/Profile.dart';

class LoginController extends GetxController {
  //variables
  final emailRememberMe = false.obs;
  final hideEmailPassword = true.obs;
  final phoneRememberMe = false.obs;
  final hidePhonePassword = true.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final emailPasswordController = TextEditingController();
  final phonePasswordController = TextEditingController();
  final countryCode = Rxn<CountryCode>();
  final localStorage = GetStorage();
  final NetworkManager _networkManager = Get.put(NetworkManager());
  final AuthRepository _authRepository = Get.put(AuthRepository());

  final userController = Get.put(UserController());

  @override
  void onInit() {
    // emailController.text = localStorage.read('REMEMBER_ME_EMAIL');
    // emailPasswordController.text = localStorage.read('REMEMBER_ME_EMAIL_PASSWORD');
    // phonePasswordController.text = localStorage.read('REMEMBER_ME_PHONE_PASSWORD');
    super.onInit();
  }

  void onCountryChanged(CountryCode code) {
    countryCode.value = code;
  }

  @override
  void onClose() {
    phoneController.dispose();
    phonePasswordController.dispose();
    super.onClose();
  }

  Future<void> loginWithEmailPassword(GlobalKey<FormState>? formKey) async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logging you in..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) return;

      //Form Validation
      if (formKey != null && !formKey.currentState!.validate()) {
        // FullscreenLoader.stopLoading();
        return;
      }

      if (emailRememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', emailController.text.trim());
        localStorage.write(
            'REMEMBER_ME_EMAIL_PASSWORD', emailPasswordController.text.trim());
      }

      // login with backend
      final resultByEmail = await _authRepository.loginWithEmail(
          emailController.text.trim(), emailPasswordController.text.trim());

      if (resultByEmail != null &&
          resultByEmail != "error credentials" &&
          resultByEmail != "Unauthenticated") {
        // Résultat valide : On écrit dans le localStorage
        localStorage.write('AUTH_TOKEN', resultByEmail['token']);
        localStorage.write('USER_PROFILE', resultByEmail['user']);
        final json = await _authRepository.getProfileByToken(resultByEmail);
        Profile profile = Profile.fromJson(json);
        localStorage.write('FULL_NAME', profile.user?.fullName);
        localStorage.write('AVATAR', profile.user?.avatar);
      } else {
        // Résultat invalide ou erreur : Afficher un message d'erreur approprié
        DLoader.errorSnackBar(title: 'OH Snap!', message: resultByEmail);
      }

      // Register user in the Firebase Auth
      // final userCredential = await AuthRepository.instance.loginWithEmailFirebase(emailController.text.trim(), emailPasswordController.text.trim());

      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your successfuly loggin in.');
      localStorage.write('AUTH_TOKEN', resultByEmail['token']);
      localStorage.write('USER_PROFILE', resultByEmail['user']);
      _authRepository.screenRedirect();

      // Future.delayed(const Duration(milliseconds: 100), () {
      //   Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
      // });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: 'Erreur de saisie');
    } finally {
      FullscreenLoader.stopLoading();
    }
  }

  // login with phone number
  Future<void> loginWithPhonePassword(GlobalKey<FormState>? formKey) async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logging you in..',
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

      //Form Validation
      if (formKey != null && !formKey.currentState!.validate()) {
        FullscreenLoader.stopLoading();
        return;
      }

      if (phoneRememberMe.value) {
        localStorage.write('REMEMBER_ME_PHONE', phoneController.text.trim());
        localStorage.write(
            'REMEMBER_ME_PHONE_PASSWORD', phonePasswordController.text.trim());
      }

      // Construire le numéro de téléphone complet avec le code pays
      final fullPhoneNumber =
          countryCode.value?.dialCode ?? '+222' + phoneController.text.trim();
      final phoneNumber = fullPhoneNumber; // Garder le + pour le backend

      print("Backend phone number = $phoneNumber");
      print("Firebase phone number = $fullPhoneNumber");

      // login with backend
      final resultByPhone = await _authRepository.loginWithPhone(
          phoneNumber, phonePasswordController.text.trim());

      if (resultByPhone != null && resultByPhone['token'] != null) {
        // Résultat valide : On écrit dans le localStorage
        print('GET_TOKEN: ${resultByPhone['token']}');
        localStorage.write('AUTH_TOKEN', resultByPhone['token']);
        localStorage.write('USER_PROFILE', resultByPhone['user']);

        // Connexion réussie via le backend
        FullscreenLoader.stopLoading();

        // Show Success Message
        DLoader.successSnackBar(
            title: 'Félicitations', message: 'Connexion réussie');

        // Navigate directly to home screen
        Get.offAll(() => const HomeScreen());
      } else {
        // Résultat invalide ou erreur
        FullscreenLoader.stopLoading();
        DLoader.errorSnackBar(
            title: 'Erreur', message: 'Identifiants invalides');
      }
    } catch (e) {
      print('Login Error: $e');
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(
          title: 'Erreur', message: 'Une erreur est survenue');
    }
  }

  // -- Google SignIn Authentication
  Future<void> googleSign() async {
    try {
      // Start Loading...
      FullscreenLoader.openDialog('Logging you in..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) {
        FullscreenLoader.stopLoading();
        return;
      }

      // google Authentication
      final userCredentials = await _authRepository.signInWithGoogle();

      var token = FirebaseAuth.instance.currentUser;
      final idToken = await token!.getIdToken();
      print("FIREBASE_TOKEN = $idToken");
      localStorage.write('FIREBASE_TOKEN', idToken);

      // Save User Record
      await userController.saveUserRecord(userCredentials);

      FullscreenLoader.stopLoading();

      AuthRepository.instance.screenRedirect();
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your are login in');
    } catch (e) {
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // -- Facebbok SignIn Authentication
  Future<void> facebookSign() async {
    try {
      // Start Loading...
      FullscreenLoader.openDialog('Logging you in..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) {
        FullscreenLoader.stopLoading();
        return;
      }

      // google Authentication
      final userCredentials = await _authRepository.signInWithFacebook();

      var token = FirebaseAuth.instance.currentUser;
      final idToken = await token!.getIdToken();
      print("FIREBASE_TOKEN = $idToken");
      localStorage.write('FIREBASE_TOKEN', idToken);
      // Once signed in, return the UserCredential

      // Save User Record
      await userController.saveUserRecord(userCredentials);

      FullscreenLoader.stopLoading();

      // AuthRepository.instance.screenRedirect();
      Get.to(() => const HomeScreen());

      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your are login in');
    } catch (e) {
      FullscreenLoader.stopLoading();
      DLoader.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    try {
      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) return;
      // Start Loading
      FullscreenLoader.openDialog('Verifying code..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Verify the SMS code
      await _authRepository.signInWithSmsCode(smsCode);

      // User successfully signed in
      FullscreenLoader.stopLoading();
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your account has been verified!');

      // AuthRepository.instance.screenRedirect();

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

  Future<void> logout() async {
    try {
      // Start Loading
      FullscreenLoader.openDialog('Logout you in..',
          'https://lottie.host/43dea365-1147-49a8-9a82-ea03cce809c9/1IDp8Ubc18.json');

      // Check Internet Connectivity
      final isConnected = await _networkManager.isConnected();
      if (!isConnected) return;

      if (emailRememberMe.value) {
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_EMAIL_PASSWORD');
      }

      // login with backend
      await _authRepository.logOutBackend(localStorage.read('AUTH_TOKEN'));
      localStorage.remove('AUTH_TOKEN');
      localStorage.remove('USER_PROFILE');
      // localStorage.remove('FCM_TOKEN');

      //Remove Loader
      FullscreenLoader.stopLoading();

      /// Show Success Message
      DLoader.successSnackBar(
          title: 'Congratulation', message: 'Your successfuly loggin in.');

      AuthRepository.instance.screenRedirect();

      // Future.delayed(const Duration(milliseconds: 100), () {
      //   Get.to(() =>  VerifyEmailScreen(email: emailController.text.trim(),));
      // });
    } catch (e) {
      DLoader.errorSnackBar(title: 'OH Snap!', message: e.toString());
    } finally {
      FullscreenLoader.stopLoading();
    }
  }

  void toggleForSell(bool value) {
    phoneRememberMe.value = value;
  }
}
