
import 'package:get/get.dart';
import '';
import 'controller.dart';

class ChatBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<ChatController>(() => ChatController());
  }

}