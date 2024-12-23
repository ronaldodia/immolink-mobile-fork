import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_state.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_email_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_phone_bloc.dart';
import 'package:immolink_mobile/controllers/signup/signup_controller.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/phone_register_confirmation_screen.dart';
import 'package:immolink_mobile/views/screens/register_phone_screen.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterEmailScreen> {

  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var buttonHeight = screenSize.height * 0.05;
    var textSize = screenSize.width * 0.035;

    return Scaffold(
      appBar: AppBar(title: const Text(''),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(Config.registerTitle, style: Theme.of(context).textTheme.headlineMedium,),
              const SizedBox(height: TSizes.spaceBtwSections,),
              /// Form
              SizedBox(
                child: _registerWithEmailPassword(context, textSize, buttonHeight)
                    // : _registerWithPhoneNumber(context, textSize, buttonHeight),
              ),
              const SizedBox(height: TSizes.spaceBtwSections,),
              const FormDividerWidget(deividerText: Config.registerOr),
              const SizedBox(height: TSizes.spaceBtwSections,),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const RegisterPhoneScreen());
                },
                child: const Center(
                  child: Text("S'enregistrer avec un numéro de téléphone"),
                ),
              ),
              const SocialAuthWidget(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _registerWithEmailPassword(BuildContext context, double textSize, double buttonHeight) {

    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final  controller = Get.put(SignupController());

    return Form(
      key: controller.emailFormKey,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  expands: false,
                  controller: controller.firstNameEmailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_2_outlined),
                      labelText: 'First Name'),
                  style: TextStyle(fontSize: textScaleFactor * 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields,),
              Expanded(
                child: TextFormField(
                  expands: false,
                  controller: controller.lastNameEmailController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_2_outlined),
                      labelText: 'Last Name'),
                  style: TextStyle(fontSize: textScaleFactor * 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields,),
          // email
          TextFormField(
            expands: false,
            controller: controller.emailController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline_outlined),
                labelText: 'E-mail'),
            style: TextStyle(fontSize: textScaleFactor * 14),
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
          const SizedBox(height: TSizes.spaceBtwInputFields),
          //password
          TextFormField(
            expands: false,
            controller: controller.passwordEmailController,
            decoration:  InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  } ,
                    icon: Icon(_obscureText ? Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                labelText: 'Password'),
            obscureText: _obscureText,
            style: TextStyle(fontSize: textScaleFactor * 14),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.passwordEmailConfirmController,
            decoration:  InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon:  IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    } ,
                    icon: Icon(_obscureText ? Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                labelText: 'Confirm Password'),
            obscureText: _obscureText,
            style: TextStyle(fontSize: textScaleFactor * 14),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != controller.passwordEmailController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Term & conditions checkbox
          Row(
            children: [
              SizedBox(width: 24, height: 24, child: Obx(
                  () => Checkbox(value: controller.privacyPolicy.value, onChanged: (value){
                    setState(() {
                      controller.privacyPolicy.value = !controller.privacyPolicy.value;
                    });
                  })
              )
              ),
              const SizedBox(width: TSizes.spaceBtwItems,),
               Text.rich(TextSpan(
                children: [
                  TextSpan(text: '${Config.isAgreeTo} & ', style: Theme.of(context).textTheme.bodySmall),
                  TextSpan(text: Config.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black
                  )),
                  TextSpan(text: Config.textAnd, style: Theme.of(context).textTheme.bodySmall),
                  TextSpan(text: Config.termsOfUse, style: Theme.of(context).textTheme.bodyMedium?.apply(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black
                  )),
                ]
              ))
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (controller.emailFormKey.currentState!.validate()) {
                  // if(controller.privacyPolicy.value == false) {
                  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez accepter les termes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow, fontSize: 30),)));
                  // }
                  final displayName = '${controller.firstNameEmailController.text} ${controller.lastNameEmailController.text}';
                  final email = controller.emailController.text;
                  final password = controller.passwordEmailController.text;
                  final confirmPassword = controller.passwordEmailConfirmController.text;

                  // await _registerEmailFirebase();
                  await controller.signupWithEmailFirebase();
                  print("User registered with firebase");
                  if(controller.privacyPolicy.value == false) {
                    DLoader.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');

                  }

                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text(
                'Create Account',
                style: TextStyle(
                    color: Colors.white, fontSize: textScaleFactor * 14),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){
            Navigator.of(context).pushReplacementNamed(loginRoute);
          }, child: const Text("I already have account")),),
        ],
      ),
    );
  }

}
