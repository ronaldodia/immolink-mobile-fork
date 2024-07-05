

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class RegisterState extends Equatable {}

final class RegisterInitial extends RegisterState {
@override
List<Object> get props => [];
}

class RegisterAuthSuccessFull extends RegisterState {

@override
List<Object> get props => [];
}

class RegisterAuthLoanding extends RegisterState {

@override
List<Object> get props => [];
}

class RegisterAuthError extends RegisterState {

final String msgError;
RegisterAuthError({required this.msgError});
@override
List<Object> get props => [msgError];
}
