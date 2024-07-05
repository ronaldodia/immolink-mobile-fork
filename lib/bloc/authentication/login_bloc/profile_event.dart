part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
}

class LoginEvent extends ProfileEvent {
  final String email;
  final String? phone;
  final String password;

   LoginEvent({ required this.email, required this.phone, required this.password});

  @override
  List<Object> get props => [email, phone!, password];
}
