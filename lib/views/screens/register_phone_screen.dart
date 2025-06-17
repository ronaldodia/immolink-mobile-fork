import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/signup/signup_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final SignupController controller = Get.put(SignupController());
  String _countryCode = '+222';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonHeight = screenSize.height * 0.05;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
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

              // Titre et sous-titre
              Text(
                Config.registerTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                Config.registerSubTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Formulaire d'inscription
              Form(
                key: controller.phoneFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: TSizes.spaceBtwSections),
                  child: Column(
                    children: [
                      // Prénom et Nom
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: controller.firstNamePhoneController,
                                decoration: const InputDecoration(
                                  hintText: 'Prénom',
                                  prefixIcon: Icon(Icons.person_2_outlined),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre prénom';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwInputFields),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: controller.lastNamePhoneController,
                                decoration: const InputDecoration(
                                  hintText: 'Nom',
                                  prefixIcon: Icon(Icons.person_2_outlined),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre nom';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),

                      // Numéro de téléphone
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
                                print(
                                    'Country code changed in view: ${code.dialCode}');
                                controller.onCountryChanged(code);
                                // Mettre à jour le numéro de téléphone avec le nouveau code pays
                                if (controller
                                    .phoneNumberController.text.isNotEmpty) {
                                  controller.updatePhoneNumber(
                                      controller.phoneNumberController.text);
                                }
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
                                controller: controller.phoneNumberController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Numéro de téléphone',
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre numéro';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  print('Phone number changed in view: $value');
                                  controller.updatePhoneNumber(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),

                      // Mot de passe
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextFormField(
                          controller: controller.passwordPhoneController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),

                      // Confirmation du mot de passe
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextFormField(
                          controller: controller.passwordPhoneConfirmController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value !=
                                controller.passwordPhoneController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Conditions d'utilisation
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: TSizes.spaceBtwInputFields),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Obx(() => Checkbox(
                                    value: controller.phoneprivacyPolicy.value,
                                    onChanged: (value) {
                                      controller.phoneprivacyPolicy.value =
                                          !controller.phoneprivacyPolicy.value;
                                    },
                                  )),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${Config.isAgreeTo} & ',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    TextSpan(
                                      text: Config.privacyPolicy,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.apply(
                                            color: Colors.blue[700],
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                    TextSpan(
                                      text: Config.textAnd,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    TextSpan(
                                      text: Config.termsOfUse,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.apply(
                                            color: Colors.blue[700],
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton d'inscription
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.phoneFormKey.currentState!
                                .validate()) {
                              if (controller.phoneprivacyPolicy.value) {
                                final phoneNumber = _countryCode +
                                    controller.phoneNumberController.text
                                        .trim();
                                print(
                                    "Numéro de téléphone final = $phoneNumber");
                                controller.signupWithPhoneFirebase();
                              } else {
                                DLoader.warningSnackBar(
                                  title: 'Acceptez les conditions',
                                  message:
                                      'Pour créer un compte, vous devez accepter les conditions d\'utilisation et la politique de confidentialité.',
                                );
                              }
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
                            'Créer un compte',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textScaleFactor * 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Lien de connexion
                      Padding(
                        padding:
                            const EdgeInsets.only(top: TSizes.spaceBtwItems),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(loginRoute),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: buttonHeight * 0.2),
                            ),
                            child: const Text("J'ai déjà un compte"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Séparateur
              const FormDividerWidget(deividerText: Config.registerOr),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Connexion sociale
              const SocialAuthWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
