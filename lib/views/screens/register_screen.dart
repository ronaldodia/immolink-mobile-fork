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
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isEmailRegister = true;
  late RegisterWithEmailBloc _registerWithEmailBloc;
  late RegisterWithPhoneBloc _registerWithPhoneBloc;

  bool _obscureText = true;
  bool _privacyPolicy = true;

  // Controllers should be initialized here
  final firstNameEmailController = TextEditingController();
  final lastNameEmailController = TextEditingController();
  final lastNamePhoneController = TextEditingController();
  final firstNamePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordEmailController = TextEditingController();
  final passwordEmailConfirmController = TextEditingController();
  final passwordPhoneController = TextEditingController();
  final passwordPhoneConfirmController = TextEditingController();
  final phoneNumberController = TextEditingController();

   late final UserRepository _userRepository;
  late final AuthRepository _authRepository;

  PhoneNumber? _phoneNumber;

  // Form keys
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _authRepository = AuthRepository();
    _registerWithEmailBloc = BlocProvider.of<RegisterWithEmailBloc>(context);
    _registerWithPhoneBloc = BlocProvider.of<RegisterWithPhoneBloc>(context);
  }

  sendEmailVerification() async {
    try{
      await _authRepository.sendEmailVerification();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error: ${e.toString()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    firstNamePhoneController.dispose();
    firstNameEmailController.dispose();
    lastNameEmailController.dispose();
    lastNamePhoneController.dispose();
    emailController.dispose();
    passwordEmailController.dispose();
    passwordEmailConfirmController.dispose();
    passwordPhoneController.dispose();
    passwordPhoneConfirmController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }


  Future<void> _registerPhoneFirebase() async {
    try {
      UserCredential userCredential = await _authRepository.registerWithEmailFirebase(
        emailController.text.trim(),
        passwordEmailController.text.trim(),
      );

      final newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: '${firstNameEmailController.text.trim()} ${lastNameEmailController.text.trim()}',
        phone: phoneNumberController.text.trim(),
      );
      await _userRepository.saveUserRecord(newUser);
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _registerEmailFirebase() async {
    try {
      UserCredential userCredential = await _authRepository.registerWithEmailFirebase(
        emailController.text.trim(),
        passwordEmailController.text.trim(),
      );

      final newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: '${firstNameEmailController.text.trim()} ${lastNameEmailController.text.trim()}',
        email: emailController.text.trim(),
      );
      await _userRepository.saveUserRecord(newUser);
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> _registerWithEmail(BuildContext context, displayName, email, password, confirmPassword) async {
  //   final response = await http.post(
  //     Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
  //     headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
  //     body: jsonEncode(<String, String>{ 'email': email!, 'full_name': displayName!, 'password': password!, 'confirm_password': confirmPassword!, 'permission': 'customer', }),
  //   );
  //
  //   final data = json.decode(response.body);
  //   print('data token: ${data['token']}');
  //
  //   final token = data['token'];
  //   context.read<AuthBloc>().add(LoggedIn(token: token));
  //   if (response.statusCode == 200) {
  //     print("User authenticated with backend");
  //     Navigator.of(context).pushReplacementNamed(accountRoute);
  //   } else {
  //     print("Failed to authenticate with backend");
  //   }
  // }

  // Future<void> _registerPhoneNumber(BuildContext context, displayName, phoneNumber, password, confirmPassword) async {
  //   final response = await http.post(
  //     Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
  //     headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
  //     body: jsonEncode(<String, String>{ 'phone': phoneNumber!, 'full_name': displayName!, 'password': password!, 'confirm_password': confirmPassword!, 'permission': 'customer', }),
  //   );
  //
  //   final data = json.decode(response.body);
  //   print('data token: ${data['token']}');
  //
  //   final token = data['token'];
  //   context.read<AuthBloc>().add(LoggedIn(token: token));
  //   if (response.statusCode == 200) {
  //     print("User authenticated with backend");
  //     Navigator.of(context).pushReplacementNamed(accountRoute);
  //   } else {
  //     print("Failed to authenticate with backend");
  //   }
  // }

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
                child: _isEmailRegister
                    ? _registerWithEmailPassword(context, textSize, buttonHeight)
                    : _registerWithPhoneNumber(context, textSize, buttonHeight),
              ),
              const SizedBox(height: TSizes.spaceBtwSections,),
              const FormDividerWidget(deividerText: Config.registerOr),
              const SizedBox(height: TSizes.spaceBtwSections,),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEmailRegister = !_isEmailRegister;
                  });
                },
                child: Center(
                  child: Text(_isEmailRegister
                      ? "S'enregistrer avec un numéro de téléphone"
                      : "S'enregistrer avec un email"),
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
                  TextSpan(text: '${Config.privacyPolicy}', style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black
                  )),
                  TextSpan(text: '${Config.textAnd}', style: Theme.of(context).textTheme.bodySmall),
                  TextSpan(text: '${Config.termsOfUse}', style: Theme.of(context).textTheme.bodyMedium?.apply(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black
                  )),
                ]
              ))
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          BlocListener<RegisterWithEmailBloc, RegisterState>(
            listener: (context, state) {
              if(state is RegisterAuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is RegisterAuthSuccessFull){

                // print(controller.emailController.text);
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EmailConfirmationScreen(email: controller.emailController.text)));
                // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is RegisterAuthError){
                DLoader.errorSnackBar(title: 'Error', message: 'jbjabj');
                // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }
            },
            child:    SizedBox(
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

                  } else {
                    _registerWithEmailBloc.add(RegisterAuthEvent(
                        full_name: displayName,
                        email: email,
                        phone: '',
                        password: password,
                        confirm_password: confirmPassword,
                        permission: 'customer'
                    ));
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
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){
            Navigator.of(context).pushReplacementNamed(loginRoute);
          }, child: const Text("I already have account")),),
        ],
      ),
    );
  }

  Widget _registerWithPhoneNumber(BuildContext context, double textSize, double buttonHeight) {
    var screenHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');
    final  controller = Get.put(SignupController());

    return Form(
      key: controller.phoneFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  expands: false,
                  controller: controller.firstNamePhoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_2_outlined),
                      labelText: 'First Name'),
                  style: TextStyle(fontSize: textScaleFactor * 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields,),
              Expanded(
                child: TextFormField(
                  expands: false,
                  controller: controller.lastNamePhoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_2_outlined),
                      labelText: 'Last Name'),
                  style: TextStyle(fontSize: textScaleFactor * 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
              ),

            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields,),
          InternationalPhoneNumberInput(

            onInputChanged: (PhoneNumber number) {
              _phoneNumber = number;
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: TextStyle(fontSize: textScaleFactor * 14),
            initialValue: initialPhoneNumber,
            textFieldController: controller.phoneNumberController,
            formatInput: false,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputDecoration: const InputDecoration(labelText: 'Phone Number'),
            inputBorder: const OutlineInputBorder(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            expands: false,
            controller: controller.passwordPhoneController,
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
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.passwordPhoneConfirmController,
            decoration:  InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
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
              if (value != controller.passwordPhoneController.text) {
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
                      () => Checkbox(value: controller.phoneprivacyPolicy.value, onChanged: (value){
                    setState(() {
                      controller.phoneprivacyPolicy.value = !controller.phoneprivacyPolicy.value;
                    });
                  })
              )
              ),
              const SizedBox(width: TSizes.spaceBtwItems,),
              Text.rich(TextSpan(
                  children: [
                    TextSpan(text: '${Config.isAgreeTo} & ', style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(text: '${Config.privacyPolicy}', style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black
                    )),
                    TextSpan(text: '${Config.textAnd}', style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(text: '${Config.termsOfUse}', style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black
                    )),
                  ]
              ))
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          BlocListener<RegisterWithPhoneBloc, RegisterState>(
            listener: (context, state) {if(state is RegisterAuthLoanding){
              const Center(child: CircularProgressIndicator(color: Colors.blue,),);
            }else if(state is RegisterAuthSuccessFull){
              // final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
              // print(phoneNumber);
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PhoneNumberConfirmationScreen(phoneNumber: phoneNumber!)));
            }else if(state is RegisterAuthError){
              DLoader.errorSnackBar(title: 'Error', message: 'jbjabj');
             }

              },
            child:  SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () async {
                  print(controller.phoneNumberController.text.trim());
                  if (controller.phoneFormKey.currentState!.validate()) {

                    final displayName = '${controller.firstNamePhoneController.text} ${controller.lastNamePhoneController.text}';
                    final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
                    final password = controller.passwordPhoneController.text;
                    final confirmPassword = controller.passwordPhoneConfirmController.text;

                    controller.phoneNumberController.text = _phoneNumber!.phoneNumber.toString();

                     controller.signupWithPhoneFirebase();


                  if(controller.phoneprivacyPolicy.value == false) {
                  DLoader.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');

                  } else {
                    _registerWithPhoneBloc.add(RegisterAuthEvent(
                        full_name: displayName,
                        email: '',
                        phone: phoneNumber,
                        password: password,
                        confirm_password: confirmPassword,
                        permission: 'customer'
                    ));
                  }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: buttonHeight * 0.2,
                      horizontal: buttonHeight * 0.5),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  'Create account',
                  style: TextStyle(
                      color: Colors.white, fontSize: textScaleFactor * 14),
                ),
              ),
            )
            ,
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
