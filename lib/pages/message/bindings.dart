import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:get/get.dart';
import '';
import 'controller.dart';

class MessageBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<MessageController>(() => MessageController());
  }

}