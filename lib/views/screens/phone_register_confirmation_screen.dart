import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/signup/signup_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneRegisterConfirmationScreen extends StatefulWidget {
  final String phoneNumber;
  final SignupController controller;

  PhoneRegisterConfirmationScreen({super.key, required this.phoneNumber})
      : controller = Get.isRegistered<SignupController>()
            ? Get.find<SignupController>()
            : Get.put(SignupController()) {
    // S'assurer que le numéro de téléphone est défini dans le contrôleur
    print(
        'PhoneRegisterConfirmationScreen - Received phone number: $phoneNumber');
    print(
        'PhoneRegisterConfirmationScreen - Controller phone number before: ${controller.phoneNumber.value}');

    if (controller.phoneNumber.value.isEmpty) {
      controller.phoneNumber.value = phoneNumber;
      print('Phone number set in controller: ${controller.phoneNumber.value}');
    } else {
      print(
          'Phone number already set in controller: ${controller.phoneNumber.value}');
    }

    // S'assurer que le contrôleur de texte contient aussi le numéro
    if (controller.phoneNumberController.text.isEmpty &&
        phoneNumber.isNotEmpty) {
      // Extraire le numéro sans le code pays pour le contrôleur de texte
      final countryCode = controller.countryCode.value?.dialCode ?? '+222';
      if (phoneNumber.startsWith(countryCode)) {
        final numberWithoutCode = phoneNumber.substring(countryCode.length);
        controller.phoneNumberController.text = numberWithoutCode;
        print('Phone number controller set to: $numberWithoutCode');
      }
    }
  }

  @override
  State<PhoneRegisterConfirmationScreen> createState() =>
      _PhoneRegisterConfirmationScreenState();
}

class _PhoneRegisterConfirmationScreenState
    extends State<PhoneRegisterConfirmationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage(TImages.smsSendImage),
                width: Helper.getScreenWidth(context) * 0.5,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
              Text(
                  'A verification code has been sent to ${widget.phoneNumber}.'),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              PinCodeTextField(
                keyboardType: TextInputType.number,
                appContext: context,
                length: 6, // Nombre de cases pour le code OTP
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.white,
                enableActiveFill: true,
                controller: _codeController,
                onCompleted: (v) {
                  print("Completed: $v");
                  // Action à effectuer lorsque le code est complet
                },
                onChanged: (value) {
                  print(value);
                  // setState(() {
                  //   // Mettre à jour l'état si nécessaire
                  // });
                },
                beforeTextPaste: (text) {
                  // Permettre le collage du texte
                  return true;
                },
              ),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying
                      ? null
                      : () async {
                          setState(() {
                            _isVerifying = true;
                          });

                          try {
                            print(
                                'Verifying SMS code: ${_codeController.text.trim()}');
                            print(
                                'Controller phone number: ${widget.controller.phoneNumber.value}');
                            await widget.controller
                                .verifySmsCode(_codeController.text.trim());
                          } catch (e) {
                            print('Error during verification: $e');
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isVerifying = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
