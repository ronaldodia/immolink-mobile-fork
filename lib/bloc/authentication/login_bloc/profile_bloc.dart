import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../repository/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  ProfileBloc(this._authRepository) : super(AuthLoanding()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoanding());
      final resultByEmail = await _authRepository.loginWithEmail(event.email, event.password);
      print('inside bloc: $resultByEmail');
      if( resultByEmail == "error credentials"){
        emit(AuthError(msgError: "Missing error"));
      }else if(resultByEmail == null){
        emit(AuthError(msgError: "Missing error"));
      }else if(resultByEmail == "Unauthenticated"){
        emit(AuthError(msgError: "Missing error"));
      }
      else{
        emit(AuthSuccessFull());
      }
    });
  }
}
