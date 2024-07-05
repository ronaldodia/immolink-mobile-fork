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

  @override
  void initState() {
    // TODO: implement initState
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

  Future<void> _registerWithEmail(BuildContext context, displayName, email,
      password, confirmPassword) async {
    final response = await http.post(
      Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email!,
        'full_name': displayName!,
        'password': password!,
        'confirm_password': confirmPassword!,
        'permission': 'customer',
      }),
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

  Future<void> _registerPhoneNumber(BuildContext context, displayName,
      phoneNumber, password, confirmPassword) async {
    final response = await http.post(
      Uri.parse('https://daar.server1.digissimmo.org/mobile/google/callback'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phoneNumber!,
        'full_name': displayName!,
        'password': password!,
        'confirm_password': confirmPassword!,
        'permission': 'customer',
      }),
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
    var textSize =
        screenSize.width * 0.035;


    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.5,
                        horizontal: buttonHeight * 0.5),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(loginRoute),
                  child: Text(
                    'I have account !',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 16),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),

              SizedBox(
                child: _isEmailRegister
                    ? _registerWithEmailPassword(context, textSize, buttonHeight)
                    : _registerWithPhoneNumber(context,  textSize, buttonHeight),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
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
                                icon: Image.asset(
                                    'assets/icons/social/apple.png'),
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

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: fullNameEmailController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: passwordEmailController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: passwordEmailConfirmController,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: screenHeight * 0.02),
          BlocListener<RegisterWithEmailBloc, RegisterState>(
            listener: (context, state){
              if(state is RegisterAuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is RegisterAuthSuccessFull){
                Navigator.of(context).pushReplacementNamed(accountRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is RegisterAuthError){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }
            },
            child: ElevatedButton(
              onPressed: () {
                print('Full Name: ${fullNameEmailController.text}');
                print('Email: ${emailController.text}');
                print('Password: ${passwordEmailController.text}');
                print('Confirm Password: ${passwordEmailConfirmController.text}');
                print('Permission: customer');

                _registerWithEmailBloc!.add(RegisterAuthEvent(full_name: fullNameEmailController.text,
                    email: emailController.text, phone: '',
                    password: passwordEmailController.text,
                    confirm_password: passwordEmailConfirmController.text, permission: 'customer'));

              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: buttonHeight * 2, vertical: buttonHeight * 0.5),
                textStyle: TextStyle(fontSize: textSize),
              ),
              child: const Text('Login with Phone Number'),
            ),

          ),

        ],
      ),
    );
  }

  Widget _registerWithPhoneNumber(BuildContext context, double textSize, double buttonHeight) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    final phoneNumberController = TextEditingController();
    final fullNameController = TextEditingController();

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: fullNamePhoneController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: screenHeight * 0.02),
          InternationalPhoneNumberInput(
            initialValue: initialPhoneNumber,
            onInputChanged: (PhoneNumber number) {
              print(number.phoneNumber);
              setState(() {
                _phoneNumber = number;
              });
            },
            onInputValidated: (bool value) {
              print(value);
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.DROPDOWN,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: const TextStyle(color: Colors.black),
            textFieldController: phoneNumberController,
            formatInput: false,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            inputDecoration: const InputDecoration(labelText: 'Phone Number'),
            locale: Localizations.localeOf(context).languageCode,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: passwordPhoneController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: buttonHeight * 1.0),
          TextField(
            controller: passwordPhoneConfirmController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: buttonHeight * 1.0),
          BlocListener<RegisterWithPhoneBloc, RegisterState>(
            listener: (context, state){
              if(state is RegisterAuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is RegisterAuthSuccessFull){
                Navigator.of(context).pushReplacementNamed(accountRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is RegisterAuthError){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }
            },
            child: ElevatedButton(
              onPressed: () {
                print('Full Name: ${fullNamePhoneController.text}');
                print('Phone: ${_phoneNumber?.phoneNumber}');
                print('Password: ${passwordPhoneController.text}');
                print('Confirm Password: ${passwordPhoneConfirmController.text}');
                print('Permission: customer');

                final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
                print('Phone Final Register: $phoneNumber');

                _registerWithPhoneBloc!.add(RegisterAuthEvent(full_name: fullNamePhoneController.text,
                    email: '', phone: phoneNumber,
                    password: passwordPhoneController.text,
                    confirm_password: passwordPhoneController.text, permission: 'customer'));

              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: buttonHeight * 2, vertical: buttonHeight * 0.5),
                textStyle: TextStyle(fontSize: textSize),
              ),
              child: const Text('Login with Phone Number'),
            ),

          ),

        ],
      ),
    );
  }
}
