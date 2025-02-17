import 'dart:convert';
import 'dart:io';

import 'package:immolink_mobile/utils/config.dart';
import 'package:http/http.dart' as http;

class APIBASE {

  Future <dynamic> emailLogin(dynamic body) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/email_token'), body: body);
    print(body);
    var responseJson = _returnResponse(response);
    return responseJson;
  }


  Future <dynamic> socialRegisterRecord(dynamic body) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/social/register'), body: body);
    print(body);
    var responseJson = _returnResponse(response);
    return responseJson;
  }


  Future<http.Response> logout(String? token) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/logout'), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
    });
    return response;
  }


  Future <dynamic> emailRegister(dynamic body) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/register_email'), body: body);
    print(body);
    var responseJson = _returnResponse(response);
    return responseJson;
  }


  Future <dynamic> phoneRegister(dynamic body) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/register_phone'), body: body);
    print(body);
    var responseJson = _returnResponse(response);
    print('inside apiBase $responseJson');
    return responseJson;
  }

  Future <dynamic> phoneLogin(dynamic body) async {
    final response = await http.post(Uri.parse('${Config.baseUrlApp}/phone_token'), body: body);
    var responseJson = _returnResponse(response);
    print('inside apiBase $responseJson');
    return responseJson;
  }

  Future <dynamic> getMyProfile(String? token) async {
    final response = await http.get(Uri.parse('${Config.baseUrlApp}/me'), headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      }, );
    return jsonDecode(response.body.toString());
  }
  
}

_returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
       var responseJson = jsonDecode(response.body.toString());
      // return responseJson['token'];
      return responseJson;
    case 422:
       var responseJson = jsonDecode(response.body.toString());
      return responseJson['message'];
    case 401:
       var responseJson = jsonDecode(response.body.toString());
      return responseJson['message'];
    default:
    return Exception('default  Error ${response.statusCode.toString()}');
  }
}