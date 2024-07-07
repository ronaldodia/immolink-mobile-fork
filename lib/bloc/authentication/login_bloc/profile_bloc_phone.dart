import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../repository/auth_repository.dart';



class ProfileBlocPhone extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  ProfileBlocPhone(this._authRepository) : super(AuthLoanding()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoanding());
      final resultByPhone = await _authRepository.loginWithPhone(event.phone, event.password);
      print('inside bloc: $resultByPhone');
      if( resultByPhone == "error credentials"){
          emit(AuthError(msgError: "Missing error"));
      }else if(resultByPhone == null){
        emit(AuthError(msgError: "Missing error"));
      }else if(resultByPhone == "Unauthenticated"){
        emit(AuthError(msgError: "Missing error"));
      }
      else{

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', resultByPhone);

        print('get auth_token ${prefs.getString('auth_token')}');
        emit(AuthSuccessFull());
      }
    });
  }
}
