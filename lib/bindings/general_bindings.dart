import 'package:get/get.dart';
import 'package:immolink_mobile/utils/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
  }

}