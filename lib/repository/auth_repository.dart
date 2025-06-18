import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/api/api_base.dart';
import 'package:immolink_mobile/models/Profile.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/views/screens/onboarding/onboarding_screen.dart';
import 'package:immolink_mobile/views/screens/verify_email_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class AuthRepository extends GetxController {
  static AuthRepository get instance => Get.find();

  // variable
  final deviceStorage = GetStorage();
  final APIBASE _apibase = APIBASE();
  final _auth = FirebaseAuth.instance;
  var authState = ''.obs;
  String verificationId = '';

  /// called from main.dart on app launch
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
    // super.onReady();
  }

  /// Function to show Relevant Screen
  screenRedirect() async {
    final user = _auth.currentUser;
    final String? authToken = deviceStorage.read('AUTH_TOKEN');
    // final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    // var userCredential = await _auth.signInWithCredential(credential);
    Get.offAll(() => const HomeScreen());
    print('================= user: $user ===================');
    if (authToken != null && authToken.isNotEmpty) {
      // L'utilisateur possède un jeton API valide, considéré comme connecté
      print('Utilisateur connecté avec un jeton API: $authToken');

      // Redirection vers l'écran principal
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAll(() => const HomeScreen());
      });
    }
    if (user != null) {
      // if(user.emailVerified){
      //   Get.offAll(() => const HomeScreen());
      // }else {
      //   Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email,));
      // }
      // Vérification si l'utilisateur est connecté avec un e-mail ou un téléphone
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        // Utilisateur authentifié via un numéro de téléphone
        print(
            'Utilisateur connecté avec un numéro de téléphone: ${user.phoneNumber}');

        // Redirection vers l'écran principal
        Get.offAll(() => const HomeScreen());
      } else if (user.email != null && user.email!.isNotEmpty) {
        // Utilisateur authentifié via e-mail
        print('Utilisateur connecté avec un e-mail: ${user.email}');

        // Vérifie si l'e-mail est vérifié
        if (user.emailVerified) {
          // Redirection vers l'écran principal
          Get.offAll(() => const HomeScreen());
        } else {
          // Si l'e-mail n'est pas vérifié, redirige vers l'écran de vérification d'e-mail
          Get.offAll(() => VerifyEmailScreen(email: user.email));
        }
      }
    } else {
      // Local Storage
      deviceStorage.writeIfNull('isFirstTime', true);
      deviceStorage.read('isFirstTime') != true
          ? Get.offAll(() => const LoginPhoneScreen())
          : Get.offAll(const OnBoardingScreen());
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginPhoneScreen());
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;
      //Create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      if (kDebugMode) print('Something went wrong. Please try again');

      // return null;
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if the login was successful
      if (result.status == LoginStatus.success) {
        // Get the user's access token
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Once signed in, return the UserCredential
        return await _auth.signInWithCredential(credential);
      } else {
        // Handle other cases such as cancellation or failure
        throw Exception('Failed to sign in with Facebook: ${result.message}');
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e, st) {
      if (kDebugMode) print('Something went wrong. Please try again $st');
      print(e.toString());
      // return null;
      throw e.toString();
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  setTimerForAutoRedirect(BuildContext context) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _auth.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) =>  EmailConfirmSuccessScreen()),
        // );
      }
    });
  }

  checkEmailVerificationStatus(BuildContext context) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) =>  EmailConfirmSuccessScreen()),
      // );
    }
  }

  // Enregistrer avec le numéro de téléphone
  Future<void> registerWithPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          // Auto-retrieve or instant validation
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          DLoader.errorSnackBar(title: 'Error', message: e.message);
          return;
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          authState.value = 'login success';
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Sign in with SMS code
  Future<void> signInWithSmsCode(String smsCode) async {
    try {
      print('Attempting to sign in with SMS code: $smsCode');
      print('Verification ID: $verificationId');
      print('Verification ID length: ${verificationId.length}');

      if (verificationId.isEmpty) {
        print('ERROR: Verification ID is empty!');
        throw 'Verification ID is missing. Please try again.';
      }

      if (smsCode.isEmpty) {
        print('ERROR: SMS code is empty!');
        throw 'SMS code is required.';
      }

      print('Creating PhoneAuthProvider credential...');
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      print('Signing in with credential...');
      var userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('User successfully signed in: ${userCredential.user!.uid}');
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print("FCM_TOKEN = $fcmToken");
        deviceStorage.write('FCM_TOKEN', fcmToken);

        print('Successfully signed in with SMS code');
        // Ne pas naviguer automatiquement ici, laisser le contrôleur gérer la navigation
      } else {
        print('ERROR: User credential is null after sign in');
        throw 'Failed to sign in with SMS code';
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during SMS verification: ${e.code} - ${e.message}');
      print('FirebaseAuthException details: ${e.toString()}');
      throw FirebaseAuthException(code: e.code);
    } on PlatformException catch (e) {
      print(
          'PlatformException during SMS verification: ${e.code} - ${e.message}');
      print('PlatformException details: ${e.toString()}');
      throw PlatformException(code: e.code);
    } catch (e) {
      print('Unexpected error during SMS verification: $e');
      print('Error type: ${e.runtimeType}');
      print('Error stack trace: ${StackTrace.current}');
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> registerWithEmailFirebase(
    String? email,
    String? password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> loginWithEmailFirebase(
    String? email,
    String? password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: e.code);
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<dynamic> registerWithEmail(String? full_name, String? email,
      String? password, String? confirm_password, String? permission) async {
    final response = await _apibase.emailRegister({
      'full_name': full_name,
      'email': email,
      'password': password,
      'confirm_password': confirm_password,
      'permission': permission
    });

    return response;
  }

  Future<dynamic> saveRegisterWithEmailFirebase(
      String? full_name,
      String? email,
      String? password,
      String? confirm_password,
      String? permission) async {
    final response = await _apibase.emailRegister(
        {'full_name': full_name, 'email': email, 'permission': 'customer'});

    return response;
  }

  Future<dynamic> loginWithEmail(String? email, String? password) async {
    final response =
        await _apibase.emailLogin({'email': email, 'password': password});

    return response;
  }

  Future<dynamic> socialRegisterRecord(
      String? fullName, String? email, String? phone, String? avatar) async {
    final response = await _apibase.socialRegisterRecord({
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    });

    return response;
  }

  Future<http.Response> logOutBackend(String? token) async {
    final response = await _apibase.logout(token!);
    final localStorage = GetStorage();
    localStorage.remove('AUTH_TOKEN');
    localStorage.remove('FCM_TOKEN');
    print('AUTH_TOKEN:  ${localStorage.read('AUTH_TOKEN')}');
    print('FCM_TOKEN_REMOVE: ${localStorage.read('FCM_TOKEN')}');

    return response;
  }

  Future<dynamic> registerWithPhone(String? full_name, String? phone,
      String? password, String? confirm_password, String? permission) async {
    final response = await _apibase.phoneRegister({
      'full_name': full_name,
      'phone': phone,
      'password': password,
      'confirm_password': confirm_password,
      'permission': permission
    });

    return response;
  }

  Future<dynamic> loginWithPhone(String? phone, String? password) async {
    final response =
        await _apibase.phoneLogin({'phone': phone!, 'password': password});
    return response;
  }

  // Enregistrer avec le numéro de téléphone
  Future<void> loginWithPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      print('Starting phone number verification for: $phoneNumber');
      print('Current verificationId before verification: $verificationId');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          print('Auto-verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.code} - ${e.message}');
          DLoader.errorSnackBar(title: 'Error', message: e.message);
          return;
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent successfully. VerificationId: $verificationId');
          this.verificationId = verificationId;
          authState.value = 'login success';
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout. VerificationId: $verificationId');
          this.verificationId = verificationId;
        },
      );

      print(
          'Phone verification process completed. Final verificationId: $verificationId');
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during phone verification: ${e.code} - ${e.message}');
      throw FirebaseAuthException(code: e.code);
    } on PlatformException catch (e) {
      print(
          'PlatformException during phone verification: ${e.code} - ${e.message}');
      throw PlatformException(code: e.code);
    } catch (e) {
      print('Unexpected error during phone verification: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  Future<dynamic> getProfileByToken(token) async {
    try {
      return await _apibase.getMyProfile(token);
    } catch (e) {
      throw 'enable to get the profile';
    }
  }

  /// Vérifie si un utilisateur existe déjà avec le numéro de téléphone donné
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      print('Checking if user exists with phone number: $phoneNumber');

      // Pour les numéros de téléphone, nous ne pouvons pas utiliser fetchSignInMethodsForEmail
      // car Firebase ne supporte pas cette méthode pour les numéros de téléphone
      // Nous allons plutôt essayer de nous connecter avec le numéro pour voir s'il existe

      // Créer un credential temporaire pour vérifier l'existence
      // Note: Cette approche peut ne pas être idéale, mais c'est une solution de contournement

      // Alternative: Vérifier via le backend si possible
      // Pour l'instant, nous retournons false pour permettre l'inscription
      // et laissons le backend gérer la validation

      print('User existence check completed - allowing registration');
      return false;
    } catch (e) {
      print('Error checking user existence: $e');
      // En cas d'erreur, on permet l'inscription et on laisse le backend valider
      return false;
    }
  }
}
