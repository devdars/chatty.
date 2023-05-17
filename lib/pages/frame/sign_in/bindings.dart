import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:get/get.dart';
import '';
import 'controller.dart';

class SignInBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<SignInController>(() => SignInController());
  }

}