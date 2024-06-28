import 'package:immolink_mobile/models/User.dart';

class Profile {
  User? user;
  List<String>? permissions;

  Profile({this.user, this.permissions});

  Profile.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    permissions = json['permissions'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['permissions'] = permissions;
    return data;
  }
}
