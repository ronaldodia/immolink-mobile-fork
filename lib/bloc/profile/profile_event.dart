import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}


class FetchProfile extends ProfileEvent {
  final String token;

  const FetchProfile({required this.token});

  @override
  List<Object> get props => [token];
}

class ProfileLoggedOut extends ProfileEvent {}
