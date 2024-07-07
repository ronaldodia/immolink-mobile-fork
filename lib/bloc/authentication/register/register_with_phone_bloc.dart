import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_event.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_state.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterWithPhoneBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  RegisterWithPhoneBloc(this._authRepository) : super(RegisterAuthLoanding()) {
    on<RegisterAuthEvent>((event, emit) async {
      emit(RegisterAuthLoanding());
      final resultByPhone = await _authRepository.registerWithPhone(event.full_name, event.phone, event.password, event.confirm_password, event.permission);
      print('inside bloc: $resultByPhone');
      if( resultByPhone == "error credentials"){
        emit(RegisterAuthError(msgError: "Missing error"));
      }else if(resultByPhone == null){
        emit(RegisterAuthError(msgError: "Missing error"));
      }else if(resultByPhone == "Unauthenticated"){
        emit(RegisterAuthError(msgError: "Missing error"));
      }
      else{

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', resultByPhone);

        print('get auth_token ${prefs.getString('auth_token')}');
        emit(RegisterAuthSuccessFull());
      }
    });
  }
}
