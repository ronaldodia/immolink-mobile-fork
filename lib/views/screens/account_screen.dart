
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/route_name.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Protected Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleLoginApi.signOut();
              context.read<AuthBloc>().add(LoggedOut());
              Navigator.of(context).pushReplacementNamed(loginRoute);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("You have accessed a protected screen"),
      ),
    );
  }
}