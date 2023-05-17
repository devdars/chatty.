
import 'package:get/get.dart';
import '';
import 'controller.dart';

class VoiceCallBinding implements Bindings{
  @override
  void dependencies(){
    Get.lazyPut<VoiceCallController>(() => VoiceCallController());
  }

}