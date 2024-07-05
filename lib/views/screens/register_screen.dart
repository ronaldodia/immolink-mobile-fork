import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_state.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_email_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_phone_bloc.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/route_name.dart';
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

  // Controllers should be initialized here
  final fullNameEmailController = TextEditingController();
  final fullNamePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordEmailController = TextEditingController();
  final passwordEmailConfirmController = TextEditingController();
  final passwordPhoneController = TextEditingController();
  final passwordPhoneConfirmController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;

  // Form keys
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _registerWithEmailBloc = BlocProvider.of<RegisterWithEmailBloc>(context);
    _registerWithPhoneBloc = BlocProvider.of<RegisterWithPhoneBloc>(context);
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    fullNameEmailController.dispose();
    fullNamePhoneController.dispose();
    emailController.dispose();
    passwordEmailController.dispose();
    passwordEmailConfirmController.dispose();
    passwordPhoneController.dispose();
    passwordPhoneConfirmController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmail(BuildContext context, displayName, email, password, confirmPassword) async {
    final response = await http.post(
      Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
      headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
      body: jsonEncode(<String, String>{ 'email': email!, 'full_name': displayName!, 'password': password!, 'confirm_password': confirmPassword!, 'permission': 'customer', }),
    );

    final data = json.decode(response.body);
    print('data token: ${data['token']}');

    final token = data['token'];
    context.read<AuthBloc>().add(LoggedIn(token: token));
    if (response.statusCode == 200) {
      print("User authenticated with backend");
      Navigator.of(context).pushReplacementNamed(accountRoute);
    } else {
      print("Failed to authenticate with backend");
    }
  }

  Future<void> _registerPhoneNumber(BuildContext context, displayName, phoneNumber, password, confirmPassword) async {
    final response = await http.post(
      Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
      headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
      body: jsonEncode(<String, String>{ 'phone': phoneNumber!, 'full_name': displayName!, 'password': password!, 'confirm_password': confirmPassword!, 'permission': 'customer', }),
    );

    final data = json.decode(response.body);
    print('data token: ${data['token']}');

    final token = data['token'];
    context.read<AuthBloc>().add(LoggedIn(token: token));
    if (response.statusCode == 200) {
      print("User authenticated with backend");
      Navigator.of(context).pushReplacementNamed(accountRoute);
    } else {
      print("Failed to authenticate with backend");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var buttonHeight = screenSize.height * 0.05;
    var textSize = screenSize.width * 0.035;

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                width: screenWidth * 0.9,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.5,
                        horizontal: buttonHeight * 0.5),
                  ),
                  onPressed: () => Navigator.of(context).pushReplacementNamed(loginRoute),
                  child: Text(
                    'I have account !',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 16),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              SizedBox(
                child: _isEmailRegister
                    ? _registerWithEmailPassword(context, textSize, buttonHeight)
                    : _registerWithPhoneNumber(context, textSize, buttonHeight),
              ),
              SizedBox(height: screenHeight * 0.05),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEmailRegister = !_isEmailRegister;
                  });
                },
                child: Text(_isEmailRegister
                    ? "S'enregistrer avec un numéro de téléphone"
                    : "S'enregistrer avec un email"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                        child: IconButton(
                          onPressed: () {},
                          icon: Image.asset('assets/icons/social/google.png'),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                        child: IconButton(
                          onPressed: () {
                            // Implement Facebook login here
                          },
                          icon: Image.asset('assets/icons/social/facebook.png'),
                        ),
                      ),
                      Platform.isIOS
                          ? SizedBox(
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                        child: IconButton(
                          onPressed: () {
                            // Implement Apple login here
                          },
                          icon: Image.asset('assets/icons/social/apple.png'),
                        ),
                      )
                          : const SizedBox(height: 0.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0), // Optional padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerWithEmailPassword(BuildContext context, double textSize, double buttonHeight) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Form(
      key: _emailFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: fullNameEmailController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: passwordEmailController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: passwordEmailConfirmController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordEmailController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            BlocBuilder<RegisterWithEmailBloc, RegisterState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_emailFormKey.currentState!.validate()) {
                        final displayName = fullNameEmailController.text;
                        final email = emailController.text;
                        final password = passwordEmailController.text;
                        final confirmPassword = passwordEmailConfirmController.text;

                        _registerWithEmailBloc.add(RegisterAuthEvent(
                          full_name: displayName,
                          email: email,
                          phone: '',
                          password: password,
                          confirm_password: confirmPassword,
                          permission: 'customer'
                        ));

                        _registerWithEmail(context, displayName, email, password, confirmPassword);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: buttonHeight * 0.2,
                          horizontal: buttonHeight * 0.5),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                          color: Colors.white, fontSize: textScaleFactor * 14),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerWithPhoneNumber(BuildContext context, double textSize, double buttonHeight) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    return Form(
      key: _phoneFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: fullNamePhoneController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: screenHeight * 0.02),
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
              textFieldController: phoneNumberController,
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
              controller: passwordPhoneController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: passwordPhoneConfirmController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordPhoneController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            BlocListener<RegisterWithPhoneBloc, RegisterState>(
              listener: (context, state) {if(state is RegisterAuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is RegisterAuthSuccessFull){
                Navigator.of(context).pushReplacementNamed(accountRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is RegisterAuthError){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }

                },
              child:  SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_phoneFormKey.currentState!.validate()) {
                      final displayName = fullNamePhoneController.text;
                      final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
                      final password = passwordPhoneController.text;
                      final confirmPassword = passwordPhoneConfirmController.text;

                      _registerWithPhoneBloc.add(RegisterAuthEvent(
                          full_name: displayName,
                          email: '',
                          phone: phoneNumber,
                          password: password,
                          confirm_password: confirmPassword,
                          permission: 'customer'
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.2,
                        horizontal: buttonHeight * 0.5),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 14),
                  ),
                ),
              )
              ,
            ),
          ],
        ),
      ),
    );
  }
}
