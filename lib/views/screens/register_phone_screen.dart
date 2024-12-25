import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/signup/signup_controller.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/screens/register_email_screen.dart';
import 'package:immolink_mobile/views/widgets/form_divider_widget.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:immolink_mobile/views/widgets/social_auth_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {

  PhoneNumber? _phoneNumber;
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
                  child: _registerWithPhoneNumber(context, textSize, buttonHeight)
                // : _registerWithPhoneNumber(context, textSize, buttonHeight),
              ),
              const SizedBox(height: TSizes.spaceBtwSections,),
              const FormDividerWidget(deividerText: Config.registerOr),
              const SizedBox(height: TSizes.spaceBtwSections,),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const RegisterEmailScreen());
                },
                child: const Center(
                  child: Text("S'enregistrer avec un email"),
                ),
              ),
              const SocialAuthWidget(),

            ],
          ),
        ),
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
              controller.onPhoneNumberChanged(number);
              // _phoneNumber = number;
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
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
                print(controller.phoneNumberController.text.trim());
                if (controller.phoneFormKey.currentState!.validate()) {

                  final phoneNumber = controller.phoneNumberInput.value!.phoneNumber!.replaceAll('+', '');
                  print("Final phone Number = $phoneNumber");
                  controller.signupWithPhoneFirebase();


                  if(controller.phoneprivacyPolicy.value == false) {
                    DLoader.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you must have to read and accept the Privacy policy & Terms of Use.');

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
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){
            Navigator.of(context).pushReplacementNamed(loginRoute);
          }, child: const Text("I already have account")),),
        ],
      ),
    );
  }

}
