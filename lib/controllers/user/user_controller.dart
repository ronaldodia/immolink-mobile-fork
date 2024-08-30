import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();



  /// Save user Record from any Registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async{
    try{
      if(userCredentials != null){
        // Map data
        final user = UserModel(
          id: userCredentials.user!.uid,
          fullName: userCredentials.user!.displayName,
          email: userCredentials.user!.email ?? '',
          phone: userCredentials.user!.phoneNumber ?? ''
        );

        // save user data
        final userRepository = Get.put(UserRepository());
        await userRepository.saveUserRecord(user);
        print('======= user created');
      }
    } catch(e){
      DLoader.warningSnackBar(
          title: 'Data not saved',
          message: 'Something went wrong while saving your information. You can re-save your data in your Profile.'
      );
    }
  }
}