import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc_phone.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/register_screen.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmailLogin = true;


  // Controllers should be initialized here
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFormEmailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();


  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    emailController.dispose();
    passwordFormEmailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var textSize =
        screenSize.width * 0.035; // Adjust text size based on screen width
    var buttonHeight =
        screenSize.height * 0.05; // Adjust button height based on screen height
// Adjust icon size based on screen width



    return Scaffold(
      // appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        // Use SingleChildScrollView to avoid RenderFlex errors when keyboard appears
        child: Padding(
          padding: SpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// logo, Title & Sub-Tile
                  const Image(image: AssetImage(TImages.darkAppLogo), height: 150,),
                  Text(Config.appLoginTitle, style: Theme.of(context).textTheme.headlineMedium,),
                  const SizedBox(height: TSizes.sm,),
                  Text(Config.appLoginSubTitle, style: Theme.of(context).textTheme.bodyMedium,),
                  

                ],
              ),

              Container(
                child: _isEmailLogin
                    ? loginWithEmailPassword(context, textSize, buttonHeight)
                    : loginWithPhoneNumber(context, textSize, buttonHeight),
              ),
              const FormDividerWidget(deividerText: Config.loginOrSignIn),

              const SizedBox(height: TSizes.spaceBtwSections,),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isEmailLogin = !_isEmailLogin;
                  });
                },
                child: Text(
                  _isEmailLogin
                      ? "Se connecter avec un numéro de téléphone"
                      : "Se connecter avec un email",
                  style: TextStyle(fontSize: textSize),
                ),
              ),

              // Footer
              const SocialAuthWidget()
            ],
          ),

        ),
      ),
    );
  }

  loginWithEmailPassword(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final controller = Get.put(LoginController());
    return Form(
      key: controller.emailLoginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outlined),
                  labelText: 'Email'
              ),
              style: TextStyle(fontSize: textSize),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields,),
            Obx(() => TextFormField(
              controller: controller.emailPasswordController,
              decoration:  InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                      onPressed: () => controller.hideEmailPassword.value = !controller.hideEmailPassword.value,
                      icon:  Icon(controller.hideEmailPassword.value ? Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                  labelText: 'Password'),
              obscureText: controller.hideEmailPassword.value,
              style: TextStyle(fontSize: textSize),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            )),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2.0),
            // Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Checkbox(value: controller.emailRememberMe.value, onChanged: (value) => controller.emailRememberMe.value  = !controller.emailRememberMe.value)),
                    const Text(Config.loginRememberMe),
                  ],
                ),

                // Forget password
                TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(forgotPasswordRoute), child: const Text("Forgot Password ?")),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.loginWithEmailPassword(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.2,
                        horizontal: buttonHeight * 0.5),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 14),
                  ),
                ),
              ),
            const SizedBox(height: TSizes.spaceBtwItems,),

            // Create account button
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Get.to(() => const RegisterScreen())
                , child: const Text("Create Account")),),
            // const SizedBox(height: TSizes.spaceBtwSections,)
          ],
        ),
      ),
    );
  }

  loginWithPhoneNumber(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Initializing PhoneNumber with Mauritania's country code
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    final controller = Get.put(LoginController());

    return Form(
      key: controller.phoneLoginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InternationalPhoneNumberInput(
              autoFocus: true,
              initialValue: initialPhoneNumber,
              onInputChanged: (PhoneNumber number) {
                print('Phone Number: ${number.phoneNumber}');
                setState(() {
                  _phoneNumber = number;
                });
              },
              onInputValidated: (bool value) {
                print(value);
              },
              selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                  setSelectorButtonAsPrefixIcon: true,
                  useBottomSheetSafeArea: true),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.black),
              textFieldController: controller.phoneController,
              formatInput: false,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputDecoration: const InputDecoration(labelText: 'Phone Number'),
              locale: Localizations.localeOf(context).languageCode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields,),
            Obx(() => TextFormField(
              controller: controller.phonePasswordController,
              decoration:  InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePhonePassword.value = !controller.hidePhonePassword.value,
                      icon: Icon(controller.hidePhonePassword.value ? Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                  labelText: 'Password'),
              obscureText: controller.hidePhonePassword.value,
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            )),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2.0),
            // Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Checkbox(value: controller.phoneRememberMe.value, onChanged: (value) => controller.phoneRememberMe.value  = !controller.phoneRememberMe.value)),
                    const Text(Config.loginRememberMe),
                  ],
                ),

                // Forget password
                TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(forgotPasswordRoute), child: const Text("Forgot Password ?")),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
            // Remember Me & Forget Password
             SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    controller.phoneController.text = _phoneNumber!.phoneNumber!.replaceAll('+', '');
                    controller.loginWithPhonePassword();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.2,
                        horizontal: buttonHeight * 0.5),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 14),
                  ),
                ),
              ),
            const SizedBox(height: TSizes.spaceBtwItems,),

            // Create account button
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){
              Navigator.of(context).pushReplacementNamed(registerRoute);
            }, child: const Text("Create Account")),),
            // const SizedBox(height: TSizes.spaceBtwSections,)
          ],
        ),
      ),
    );
  }
}
