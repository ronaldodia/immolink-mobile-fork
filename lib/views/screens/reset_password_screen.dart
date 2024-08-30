import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email, required this.phone});
  final String email;
  final String phone;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: code);
      try {
        //rajouter l'api qui va declencher la validation du compte au backend
        await _auth.signInWithCredential(credential);
        Navigator.of(context).pushReplacementNamed(homeRoute); // Remplacez '/home' par la route de votre écran principal
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre Email et bien confirmer')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to verify code')));
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var displayText = '';

    if (widget.email.isNotEmpty) {
      displayText = widget.email;
    } else if (widget.phone.isNotEmpty) {
      displayText = widget.phone;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // displayText.isNotEmpty
              //     ? Text(
              //   displayText,
              //   style: Theme.of(context).textTheme.labelLarge,
              // )
              //     : const SizedBox.shrink(),
              const SizedBox(height: TSizes.spaceBtwSections,),
              widget.email.isNotEmpty ? Column(
                children: [
                  Image(image: const AssetImage(TImages.emailSuccessfullyConfirmImage), width: Helper.getScreenWidth(context) * 0.9,),
                  const SizedBox(height: TSizes.spaceBtwSections,),
                  /// TITLE
                  Text("Your account successfully created!", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  Text(widget.email, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  Text("Welcome to your Ultimate Real Estate Destination. Your Account is Created Unieash the Joy of Seamless Real Estate Sell , Tenant & Booking",
                    style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
                  
                  const SizedBox(height: TSizes.spaceBtwSections,),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton(onPressed: () => Navigator.of(context).pushReplacementNamed(loginRoute),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("Continue", style: TextStyle(
                          color: Colors.white, fontSize: TSizes.fontSizeSm ),),),),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  SizedBox(width: double.infinity,
                    child: TextButton(onPressed: (){}, child: const Text('Resend Link', style: TextStyle(color: Colors.lightBlue),),)),
                ],
              ) :
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: const AssetImage(TImages.smsSendImage), width: Helper.getScreenWidth(context) * 0.5,),
                  const SizedBox(height: TSizes.spaceBtwSections,),
                  Text('A verification code has been sent to ${widget.phone}.'),
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
                    // backgroundColor: Colors.blue.shade50,
                    enableActiveFill: true,
                    controller: _codeController,
                    onCompleted: (v) {
                      print("Completed: $v");
                      // Action à effectuer lorsque le code est complet
                    },
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        // Mettre à jour l'état si nécessaire
                      });
                    },
                    beforeTextPaste: (text) {
                      // Permettre le collage du texte
                      return true;
                    },
                  ),
                  // TextField(
                  //   controller: _codeController,
                  //   decoration: const InputDecoration(labelText: 'Verification Code', prefixIcon: Icon(Icons.sms_outlined), border: OutlineInputBorder()),
                  // ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // onPressed: _verifyCode,
                      onPressed: (){
                        print('code ${_codeController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Verify', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  SizedBox(width: double.infinity,
                      child: TextButton(onPressed: (){
                      }, child: const Text('Resend code', style: TextStyle(color: Colors.lightBlue),),)),
                ],
              ),
            ],
          ),
        ),
    ),
    );
  }
}
