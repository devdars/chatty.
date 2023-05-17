import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:get/get.dart';
import '';

class WelcomeBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }

}