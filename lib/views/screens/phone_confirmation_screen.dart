import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:immolink_mobile/utils/route_name.dart';

class PhoneNumberConfirmationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneNumberConfirmationScreen({super.key, required this.phoneNumber});

  @override
  _PhoneNumberConfirmationScreenState createState() => _PhoneNumberConfirmationScreenState();
}

class _PhoneNumberConfirmationScreenState extends State<PhoneNumberConfirmationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Navigator.of(context).pushReplacementNamed(homeRoute);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre Email et bien confirmer')));
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number Confirmation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A verification code has been sent to ${widget.phoneNumber}.'),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
