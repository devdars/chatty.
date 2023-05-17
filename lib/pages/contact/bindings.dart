import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:get/get.dart';
import '';
import 'controller.dart';

class ContactBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<ContactController>(() => ContactController());
  }

}