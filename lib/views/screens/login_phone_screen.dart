import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/register_phone_screen.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  late final LoginController controller;
  String _countryCode = '+222';
  final _formKey =
      GlobalKey<FormState>(); // Clé locale pour éviter les conflits

  @override
  void initState() {
    super.initState();
    // Utiliser Get.find() pour récupérer l'instance existante ou en créer une nouvelle
    if (Get.isRegistered<LoginController>()) {
      controller = Get.find<LoginController>();
    } else {
      controller = Get.put(LoginController());
    }
  }

  @override
  void dispose() {
    // Ne pas supprimer le contrôleur ici car il peut être utilisé ailleurs
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final buttonHeight = screenSize.height * 0.05;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: SpacingStyles.paddingWithAppBarHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo et titre
                const Center(
                  child: Image(
                    image: AssetImage(TImages.darkAppLogo),
                    height: 150,
                  ),
                ),

                // Bouton d'accès direct
                Center(
                  child: TextButton.icon(
                    onPressed: () => Get.off(() => const HomeScreen()),
                    icon: const Icon(Icons.home_outlined, color: Colors.blue),
                    label: Text(
                      l10n.continue_without_login,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Titre et sous-titre
                Text(
                  Config.appLoginTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  Config.appLoginSubTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Formulaire de connexion
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: TSizes.spaceBtwSections),
                    child: Column(
                      children: [
                        // Champ de numéro de téléphone
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              CountryCodePicker(
                                onChanged: (CountryCode code) {
                                  setState(() {
                                    _countryCode = code.dialCode!;
                                  });
                                  controller.onCountryChanged(code);
                                },
                                initialSelection: 'MR',
                                favorite: const ['MR', 'SN', 'ML'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: 'Numéro de téléphone',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre numéro de téléphone';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    controller.phoneController.text = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Champ de mot de passe
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Obx(() => TextFormField(
                                controller: controller.phonePasswordController,
                                obscureText: controller.hidePhonePassword.value,
                                decoration: InputDecoration(
                                  hintText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        controller.hidePhonePassword.value =
                                            !controller.hidePhonePassword.value,
                                    icon: Icon(
                                      controller.hidePhonePassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  return null;
                                },
                              )),
                        ),

                        // Se souvenir de moi et mot de passe oublié
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: TSizes.spaceBtwInputFields / 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Obx(() => Checkbox(
                                        value: controller.phoneRememberMe.value,
                                        onChanged: (value) => controller
                                                .phoneRememberMe.value =
                                            !controller.phoneRememberMe.value,
                                      )),
                                  const Text(Config.loginRememberMe),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed(forgotPasswordRoute),
                                child: const Text("Mot de passe oublié ?"),
                              ),
                            ],
                          ),
                        ),

                        // Bouton de connexion
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final phoneNumber = _countryCode +
                                    controller.phoneController.text
                                        .replaceAll(_countryCode, '');
                                print(
                                    "Numéro de téléphone final = $phoneNumber");
                                await controller
                                    .loginWithPhonePassword(_formKey);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.2),
                            ),
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textScaleFactor * 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Bouton de création de compte
                        Padding(
                          padding:
                              const EdgeInsets.only(top: TSizes.spaceBtwItems),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.off(() => const RegisterPhoneScreen());
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: buttonHeight * 0.2),
                              ),
                              child: const Text("Créer un compte"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Séparateur
                const FormDividerWidget(deividerText: Config.loginOrSignIn),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Connexion avec email
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => const LoginPhoneScreen());
                    },
                    child: Text(
                      "Se connecter avec un email",
                      style: TextStyle(
                        fontSize: textScaleFactor * 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ),

                // Connexion sociale
                const SocialAuthWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
