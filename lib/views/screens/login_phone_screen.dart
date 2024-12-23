import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  PhoneNumber? _phoneNumber;


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var buttonHeight =
        screenSize.height * 0.05;
    var textSize =
        screenSize.width * 0.035;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Initializing PhoneNumber with Mauritania's country code
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    final controller = Get.put(LoginController());
    return Scaffold(
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
                TextButton(
                  onPressed: () {
                    Get.to(() => const BottomNavigationMenu()); // Navigue vers la page d'accueil
                  },
                  child: const Text("Accueil", style: TextStyle(fontSize: 16)),
                ),
                Text(Config.appLoginTitle, style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(height: TSizes.sm,),
                Text(Config.appLoginSubTitle, style: Theme.of(context).textTheme.bodyMedium,),


              ],
            ),
            Container(
              child: Form(
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
              ),

            ),
            const FormDividerWidget(deividerText: Config.loginOrSignIn),

            const SizedBox(height: TSizes.spaceBtwSections,),

            TextButton(
              onPressed: () {
                Get.offAll(() => const LoginPhoneScreen());
              },
              child: Text( "Se connecter avec un numéro de téléphone",
                style: TextStyle(fontSize: textSize),
              ),
            ),

            // Footer
            const SocialAuthWidget()
          ],
        ),
    )
      )
    );
  }
}
