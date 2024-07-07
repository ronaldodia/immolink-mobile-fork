import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_state.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterWithEmailBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  RegisterWithEmailBloc(this._authRepository) : super(RegisterAuthLoanding()) {
    on<RegisterAuthEvent>((event, emit) async {
      emit(RegisterAuthLoanding());
      final resultByEmail = await _authRepository.registerWithEmail(event.full_name, event.email, event.password, event.confirm_password, event.permission);
      print('inside bloc: $resultByEmail');
      if( resultByEmail == "error credentials"){
        emit(RegisterAuthError(msgError: "Missing error"));
      }else if(resultByEmail == null){
        emit(RegisterAuthError(msgError: "Missing error"));
      }else if(resultByEmail == "Unauthenticated"){
        emit(RegisterAuthError(msgError: "Missing error"));
      }
      else{
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', resultByEmail);

        print('get auth_token ${prefs.getString('auth_token')}');
        emit(RegisterAuthSuccessFull());
      }
    });
  }
}
