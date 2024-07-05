import 'package:immolink_mobile/api/api_base.dart';

class AuthRepository {
  
  final String _apiKey = "";
  final APIBASE _apibase = APIBASE();

  Future<dynamic> registerWithEmail(String? full_name, String? email, String? password, String? confirm_password, String? permission) async {

    final response = await _apibase.emailRegister({
      'full_name': full_name,
      'email': email,
      'password': password,
      'confirm_password': confirm_password,
      'permission': permission
    });

    return response;
  }

  Future<dynamic> loginWithEmail(String? email, String? password) async {
    
    final response = await _apibase.emailLogin({
      'email': email,
      'password': password
    });

    return response;
  }

  Future<dynamic> registerWithPhone(String? full_name, String? phone, String? password, String? confirm_password, String? permission) async {

    final response = await _apibase.phoneRegister({
      'full_name': full_name,
      'phone': phone,
      'password': password,
      'confirm_password': confirm_password,
      'permission': permission
    });

    return response;
  }

  Future<dynamic> loginWithPhone(String? phone, String? password) async {
    final response = await _apibase.phoneLogin({
      'phone': phone!,
      'password': password
    });
    return response;
  }


}