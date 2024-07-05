import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immolink_mobile/bloc/profile/profile_bloc.dart';
import 'package:immolink_mobile/bloc/profile/profile_event.dart';
import 'package:immolink_mobile/bloc/profile/profile_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future test () async {
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
              // context.read<ProfileBloc>().add(ProfileLoggedOut());
              // Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body:  Center(child: ElevatedButton(onPressed: () => test(), child: Text("Test connection")),)
    );
  }
}
