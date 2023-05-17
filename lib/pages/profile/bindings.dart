
import 'package:get/get.dart';
import '';
import 'controller.dart';

class ProfileBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<ProfileController>(() => ProfileController());
  }

}