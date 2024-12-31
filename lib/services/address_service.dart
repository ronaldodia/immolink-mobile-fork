import 'dart:convert';
import 'package:flutter/services.dart';

class AddressService {
  Future<Map<String, dynamic>> loadAddressData() async {
    final String response = await rootBundle.loadString('assets/data/address.json');
    return json.decode(response);
  }
}
