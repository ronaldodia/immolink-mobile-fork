import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';
import 'package:immolink_mobile/controllers/signup/signup_controller.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneLoginConfirmationScreen extends StatelessWidget {
  final String phoneNumber;

  PhoneLoginConfirmationScreen({super.key, required this.phoneNumber});

  final TextEditingController _codeController = TextEditingController();
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () =>  AuthRepository.instance.logout(), icon: const Icon(Icons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: const AssetImage(TImages.smsSendImage), width: Helper.getScreenWidth(context) * 0.5,),
              const SizedBox(height: TSizes.spaceBtwSections,),
              Text('A verification code has been sent to $phoneNumber.'),
              const SizedBox(height: TSizes.spaceBtwItems,),

              PinCodeTextField(
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
              const SizedBox(height: TSizes.spaceBtwItems,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.verifySmsCode(_codeController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Verify', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
