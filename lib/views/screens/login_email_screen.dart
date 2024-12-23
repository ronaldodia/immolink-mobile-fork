import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/views/screens/register_email_screen.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginEmailScreen> {
  bool _isEmailLogin = true;


  // Controllers should be initialized here
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFormEmailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;


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
    final controller = Get.put(LoginController());
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
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
                        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Get.to(() => const RegisterEmailScreen())
                            , child: const Text("Create Account")),),
                        // const SizedBox(height: TSizes.spaceBtwSections,)
                      ],
                    ),
                  ),
                )
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

        ),
      ),
    );
  }


}
