part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {}

final class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class AuthSuccessFull extends ProfileState {

@override
List<Object> get props => [];
}

class AuthLoanding extends ProfileState {

@override
List<Object> get props => [];
}

class AuthError extends ProfileState {

   final String msgError;
    AuthError({required this.msgError});
@override
List<Object> get props => [msgError];
}
