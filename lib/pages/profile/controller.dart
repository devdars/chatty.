import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/user.dart';
import 'package:chatty/pages/frame/welcome/state.dart';
import 'package:chatty/pages/profile/state.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileController extends GetxController{
  ProfileController();
  final title="Chatty .";
  final state=ProfileState();

  @override
  void onInit(){
    super.onInit();
    var userItem = Get.arguments;
    if(userItem != null){
      state.profileDetail.value=userItem;
    }
  }


 Future<void> goLogout() async {
    await GoogleSignIn().signOut();
    await UserStore.to.onLogout();
 }
}