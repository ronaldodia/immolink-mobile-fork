import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc_phone.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmailLogin = true;
   late ProfileBlocPhone _authBloc;
  late ProfileBloc _authBlocEmail;

  // Controllers should be initialized here
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFormEmailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authBlocEmail = BlocProvider.of<ProfileBloc>(context);
    _authBloc = BlocProvider.of<ProfileBlocPhone>(context);
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    emailController.dispose();
    passwordFormEmailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    var user = await GoogleLoginApi.login();
    if (user != null) {
      print("ok !");
      print(user.displayName);
      print(user.email);
      await _authenticateWithBackend(context, user.displayName, user.email);
    }
  }

  Future<void> _authenticateWithBackend(
      BuildContext context, displayName, email) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrlApp}/google/callback'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email!,
        'full_name': displayName!,
      }),
    );

    final data = json.decode(response.body);
    print('data token: ${data['token']}');

    final token = data['token'];
    context.read<AuthBloc>().add(LoggedIn(token: token));
    // context.read<ProfileBloc>().add(FetchProfile(token: token));
    if (response.statusCode == 200) {
      print("User authenticated with backend");
      Navigator.of(context).pushReplacementNamed(accountRoute);
    } else {
      print("Failed to authenticate with backend");
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content:
            const Text("Please check your internet connection and try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithPhone(BuildContext context, phone, password) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog(context);
      return;
    }

    // Removing the '+' from the phone number
    final phoneNumber = phone.replaceAll('+', '');
    final response = await http.post(
      Uri.parse('${Config.baseUrlApp}/phone_token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phoneNumber,
        'password': password,
      }),
    );
    final data = json.decode(response.body);
    print('data token: ${data['token']}');

    final token = data['token'];
    context.read<AuthBloc>().add(LoggedIn(token: token));
    // context.read<ProfileBloc>().add(FetchProfile(token: token));
    if (response.statusCode == 200) {
      print("User authenticated with backend");
      Navigator.of(context).pushReplacementNamed(accountRoute);
    } else if(response.statusCode == 401){
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("AUTHORIZATION"),
        content:
            const Text("Vous n'avez pas access a cette section"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    } else if(response.statusCode == 422){
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur de Saisi"),
        content:
            const Text("Veuillez saisir les bon donnees"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    }
     else {
      print("Failed to authenticate with backend");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var textSize =
        screenSize.width * 0.035; // Adjust text size based on screen width
    var buttonHeight =
        screenSize.height * 0.05; // Adjust button height based on screen height
    var iconSize =
        screenSize.width * 0.2; // Adjust icon size based on screen width
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        // Use SingleChildScrollView to avoid RenderFlex errors when keyboard appears
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenSize.height * 0.1,
            ),
            SizedBox(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(
                      vertical: buttonHeight * 0.5,
                      horizontal: buttonHeight * 0.5),
                ),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(registerRoute),
                child: Text(
                  'Create account ?',
                  style: TextStyle(color: Colors.white, fontSize: textSize),
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.1,
            ),
            Container(
              child: _isEmailLogin
                  ? loginWithEmailPassword(context, textSize, buttonHeight)
                  : loginWithPhoneNumber(context, textSize, buttonHeight),
            ),
            SizedBox(
              height: screenSize.height * 0.1,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEmailLogin = !_isEmailLogin;
                });
              },
              child: Text(
                _isEmailLogin
                    ? "Se connecter avec un numéro de téléphone"
                    : "Se connecter avec un email",
                style: TextStyle(fontSize: textSize),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: iconSize,
                    width: iconSize,
                    child: IconButton(
                      onPressed: () => loginWithGoogle(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: iconSize * 0.15,
                            vertical: iconSize * 0.1),
                      ),
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
          ],
        ),
      ),
    );
  }

  loginWithEmailPassword(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            style: TextStyle(fontSize: textSize),
          ),
          TextField(
            controller: passwordFormEmailController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            style: TextStyle(fontSize: textSize),
          ),
          SizedBox(height: buttonHeight * 1.0),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state){
              if(state is AuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is AuthSuccessFull){
                Navigator.of(context).pushReplacementNamed(accountRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is AuthError){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }
            },
            child: ElevatedButton(
              onPressed: () {
                print('Email: ${emailController.text}');
                print('Password: ${passwordFormEmailController.text}');

                _authBlocEmail!.add(LoginEvent(email: emailController.text, phone: '', password: passwordFormEmailController.text));

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

  loginWithPhoneNumber(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Initializing PhoneNumber with Mauritania's country code
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InternationalPhoneNumberInput(
            autoFocus: true,
            initialValue: initialPhoneNumber,
            onInputChanged: (PhoneNumber number) {
              print('Phone Number: ${number.phoneNumber}');
              setState(() {
                _phoneNumber = number;
              });
            },
            onInputValidated: (bool value) {
              print(value);
            },
            selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
                setSelectorButtonAsPrefixIcon: true,
                useBottomSheetSafeArea: true),
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
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            style: TextStyle(fontSize: textScaleFactor * 14),
          ),
          SizedBox(height: buttonHeight * 1.0),
          BlocListener<ProfileBlocPhone, ProfileState>(
            listener: (context, state){
              if(state is AuthLoanding){
                const Center(child: CircularProgressIndicator(color: Colors.blue,),);
              }else if(state is AuthSuccessFull){
                Navigator.of(context).pushReplacementNamed(accountRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 30),)));
              }else if(state is AuthError){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 30),)));
              }
            },
            child: ElevatedButton(
              onPressed: () {
                print('Phone: ${_phoneNumber?.phoneNumber}');
                print('Password: ${passwordController.text}');
                final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
                print('Phone Final: $phoneNumber');

                _authBloc!.add(LoginEvent(email: '', phone: phoneNumber, password: passwordController.text));

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
