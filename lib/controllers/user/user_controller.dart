import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/models/User.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/repository/user_repository.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final localStorage = GetStorage();



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
        // save to backend
        final authRepository = Get.put(AuthRepository());
        final backToken = await authRepository.socialRegisterRecord(
            userCredentials.user!.displayName,
            userCredentials.user!.email ?? '',
            userCredentials.user!.phoneNumber ?? '',
            userCredentials.user!.photoURL ?? '',
        );
        // Résultat valide : On écrit dans le localStorage
        localStorage.write('AUTH_TOKEN', backToken);
        print('======= token created ===========');
        print(backToken);
      }
    } catch(e){
      DLoader.warningSnackBar(
          title: 'Data not saved',
          message: 'Something went wrong while saving your information. You can re-save your data in your Profile.'
      );
    }
  }
}