import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'dart:convert';
import 'dart:io';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfile) {
      yield ProfileLoading();
      try {
        final user = await _fetchUser(event.token);
        if (user != null) {
          yield ProfileLoaded(user: user);
        } else {
          yield const ProfileError(message: "Failed to fetch user profile.");
        }
      } catch (e) {
        yield ProfileError(message: e.toString());
      }
    } else if (event is ProfileLoggedOut) {
      yield ProfileInitial();
    }
  }

  Future<UserModel?> _fetchUser(String token) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrlApp}/me'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data['user']);
    }

    return null;
  }
}
