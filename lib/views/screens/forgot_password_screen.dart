import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/reset_password_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;
  bool _isEmailRegister = true;

  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text('Forgot Password', style: Theme.of(context).textTheme.headlineMedium,),
            const  SizedBox(height: TSizes.spaceBtwItems,),
            Text("Don't Worry sometimes people can forget too, enter you email and we will send you a password reset link", style: Theme.of(context).textTheme.labelMedium,),
            const  SizedBox(height: TSizes.spaceBtwSections * 2,),

            SizedBox(
              child: _isEmailRegister ? _forgotPasswordWithEmail(context) : _forgotPasswordWithPhone(context),
            ),
            const SizedBox(height: TSizes.spaceBtwSections,),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEmailRegister = !_isEmailRegister;
                });
              },
              child: Center(
                child: Text(_isEmailRegister
                    ? "Recuperer avec mon N de Telephone"
                    : "Recuperer avec mon Email"),
              ),
            ),
            // Submit Button
          ],
        ),
      ),
    );
  }


  // forgot password with email
  Widget _forgotPasswordWithEmail(BuildContext context,){

    return SizedBox(
      child: Column(
        children: [
          // TextField
          Form(
            key: _emailFormKey,
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline_outlined), border: OutlineInputBorder()),
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
          ),
          const  SizedBox(height: TSizes.spaceBtwSections,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_emailFormKey.currentState!.validate()) {
                  print('forgot email ${emailController.text}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ResetPasswordScreen(email: emailController.text, phone: '')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // forgot password with phone
  Widget _forgotPasswordWithPhone(BuildContext context,){
    final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'MR');
    return SizedBox(
      child: Column(
        children: [
          // TextField
          Form(
            key: _phoneFormKey,
            child:  InternationalPhoneNumberInput(

              onInputChanged: (PhoneNumber number) {
                _phoneNumber = number;
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              // selectorTextStyle: TextStyle(fontSize: textScaleFactor * 14),
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
          ),
          const  SizedBox(height: TSizes.spaceBtwSections,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_phoneFormKey.currentState!.validate()) {
                  final phoneNumber = _phoneNumber?.phoneNumber!;
                  print('forgot phone $phoneNumber');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ResetPasswordScreen(email: '', phone: phoneNumber!,)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
