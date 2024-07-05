
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class RegisterEvent extends Equatable {
}

class RegisterAuthEvent extends RegisterEvent {
  final String full_name;
  final String email;
  final String? phone;
  final String password;
  final String confirm_password;
  final String permission;

  RegisterAuthEvent({required this.full_name, required this.email, required this.phone, required this.password, required this.confirm_password, required this.permission});

  @override
  List<Object> get props => [full_name, email, phone!, password, confirm_password, permission];
}
