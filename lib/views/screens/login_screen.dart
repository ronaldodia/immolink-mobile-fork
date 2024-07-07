import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc_phone.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/spacing_styles.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

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
      // appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        // Use SingleChildScrollView to avoid RenderFlex errors when keyboard appears
        child: Padding(
          padding: SpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// logo, Title & Sub-Tile
                  const Image(image: AssetImage(TImages.darkAppLogo), height: 150,),
                  Text(Config.appLoginTitle, style: Theme.of(context).textTheme.headlineMedium,),
                  const SizedBox(height: TSizes.sm,),
                  Text(Config.appLoginSubTitle, style: Theme.of(context).textTheme.bodyMedium,),
                  // SizedBox(
                  //   height: screenSize.height * 0.1,
                  // ),
                  // SizedBox(
                  //   child: TextButton(
                  //     style: TextButton.styleFrom(
                  //       backgroundColor: Colors.blueAccent,
                  //       padding: EdgeInsets.symmetric(
                  //           vertical: buttonHeight * 0.5,
                  //           horizontal: buttonHeight * 0.5),
                  //     ),
                  //     onPressed: () =>
                  //         Navigator.of(context).pushReplacementNamed(registerRoute),
                  //     child: Text(
                  //       'Create account ?',
                  //       style: TextStyle(color: Colors.white, fontSize: textSize),
                  //     ),
                  //   ),
                  // ),

                ],
              ),
              Container(
                child: _isEmailLogin
                    ? loginWithEmailPassword(context, textSize, buttonHeight)
                    : loginWithPhoneNumber(context, textSize, buttonHeight),
              ),
              const FormDividerWidget(deividerText: Config.loginOrSignIn),

              const SizedBox(height: TSizes.spaceBtwSections,),

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

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                          onPressed: () => loginWithGoogle(context),
                          icon: const Image(
                            width: TSizes.iconMd,
                            height: TSizes.iconMd,
                            image: AssetImage(TImages.google),
                          ),
                        ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems,),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        width: TSizes.iconMd,
                        height: TSizes.iconMd,
                        image: AssetImage(TImages.facebook),
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems,),
                  Platform.isIOS ?
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        width: TSizes.iconMd,
                        height: TSizes.iconMd,
                        image: AssetImage(TImages.apple),
                      ),
                    ),
                  ) : const SizedBox(height: 0.0),
                  
                ],
              ),
            ],
          ),

        ),
      ),
    );
  }

  loginWithEmailPassword(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Form(
      key: _emailFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outlined),
                  labelText: 'Email'
              ),
              style: TextStyle(fontSize: textSize),
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
            const SizedBox(height: TSizes.spaceBtwInputFields,),
            TextFormField(
              controller: passwordFormEmailController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.remove_red_eye_outlined),
                  labelText: 'Password'),
              obscureText: true,
              style: TextStyle(fontSize: textSize),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2.0),
            // Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value){}),
                    const Text(Config.loginRememberMe),
                  ],
                ),

                // Forget password
                TextButton(onPressed: (){}, child: const Text("Forget Password ?")),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                  if (_emailFormKey.currentState!.validate()) {
                      final email = emailController.text;
                      final password = passwordFormEmailController.text;
                      print('Email: $email');
                      print('Password: $password');

                      _authBlocEmail!.add(LoginEvent(email: emailController.text, phone: '', password: passwordFormEmailController.text));
                  }

                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.2,
                        horizontal: buttonHeight * 0.5),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 14),
                  ),
                ),
              ),

            ),
            const SizedBox(height: TSizes.spaceBtwItems,),

            // Create account button
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){}, child: const Text("Create Account")),),
            // const SizedBox(height: TSizes.spaceBtwSections,)
          ],
        ),
      ),
    );
  }

  loginWithPhoneNumber(
      BuildContext context, double textSize, double buttonHeight) {
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Initializing PhoneNumber with Mauritania's country code
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');

    return Form(
      key: _phoneFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InternationalPhoneNumberInput(
              autoFocus: true,
              // initialValue: initialPhoneNumber,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields,),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.remove_red_eye_outlined),
                  labelText: 'Password'),
              obscureText: true,
              style: TextStyle(fontSize: textScaleFactor * 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2.0),
            // Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value){}),
                    const Text(Config.loginRememberMe),
                  ],
                ),

                // Forget password
                TextButton(onPressed: (){}, child: const Text("Forget Password ?")),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
            // Remember Me & Forget Password
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
              child: SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                  if (_phoneFormKey.currentState!.validate()) {

                    final phoneNumber = _phoneNumber?.phoneNumber!.replaceAll('+', '');
                    final password = passwordController.text;
                    print('Phone: ${_phoneNumber?.phoneNumber}');
                    print('Password: $password');
                    print('Phone Final: $phoneNumber');

                    _authBloc!.add(LoginEvent(email: '', phone: phoneNumber, password: password));
                  }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonHeight * 0.2,
                        horizontal: buttonHeight * 0.5),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontSize: textScaleFactor * 14),
                  ),
                ),
              ),

            ),
            const SizedBox(height: TSizes.spaceBtwItems,),

            // Create account button
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){}, child: const Text("Create Account")),),
            // const SizedBox(height: TSizes.spaceBtwSections,)
          ],
        ),
      ),
    );
  }
}
