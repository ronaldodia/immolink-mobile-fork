import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';

import 'package:immolink_mobile/services/google_login_api.dart';
import 'package:immolink_mobile/utils/route_name.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      Uri.parse('https://daar.server1.digissimmo.org/api/google/callback'),
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
    if (response.statusCode == 200) {
      print("User authenticated with backend");
      Navigator.of(context).pushReplacementNamed(accountRoute);
    } else {
      print("Failed to authenticate with backend");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with Google")),
      body: Center(
        child: ElevatedButton(
          // onPressed: () => loginWithGoogle(context),
          onPressed: () => loginWithGoogle(context),
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
