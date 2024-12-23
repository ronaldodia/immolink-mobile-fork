import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/models/User.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserRecord(UserModel user) async {

    try{
       await _db.collection("Users").doc(user.id).set(user.toJson());

    } on FirebaseAuthException catch(e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch(e) {
      throw FirebaseException(plugin: e.code);
    }on FormatException catch(e) {
      throw FormatException(e.message);
    }on PlatformException catch(e) {
      throw PlatformException(code: e.code);
    } catch(e) {
      throw 'Something went wrong. Please try again';
    }
  }
}