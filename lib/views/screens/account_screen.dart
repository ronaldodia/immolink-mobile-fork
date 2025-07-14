import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future test() async {
    AuthRepository authRepository = AuthRepository();
    await authRepository.loginWithPhone('22241905565', 'password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Protected Screen"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await GoogleSignIn().signOut();
              },
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () => test(), child: const Text("Test connection")),
        ));
  }
}
