
import 'package:flutter/material.dart';
import 'package:chatty/common/middlewares/middlewares.dart';

import 'package:get/get.dart';

import '../../pages/contact/bindings.dart';
import '../../pages/contact/view.dart';
import '../../pages/frame/sign_in/bindings.dart';
import '../../pages/frame/sign_in/view.dart';
import '../../pages/frame/welcome/index.dart';
import '../../pages/message/voicecall/index.dart';
import '../../pages/message/bindings.dart';
import '../../pages/message/chat/bindings.dart';
import '../../pages/message/chat/view.dart';
import '../../pages/message/view.dart';
import '../../pages/profile/bindings.dart';
import '../../pages/profile/view.dart';
import 'routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    // about to boot up the app
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),

    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),
    /*
    // 需要登录
    // GetPage(
    //   name: AppRoutes.Application,
    //   page: () => ApplicationPage(),
    //   binding: ApplicationBinding(),
    //   middlewares: [
    //     RouteAuthMiddleware(priority: 1),
    //   ],
    // ),

    // 最新路由
    GetPage(name: AppRoutes.EmailLogin, page: () => EmailLoginPage(), binding: EmailLoginBinding()),
    GetPage(name: AppRoutes.Register, page: () => RegisterPage(), binding: RegisterBinding()),
    GetPage(name: AppRoutes.Forgot, page: () => ForgotPage(), binding: ForgotBinding()),
    GetPage(name: AppRoutes.Phone, page: () => PhonePage(), binding: PhoneBinding()),
    GetPage(name: AppRoutes.SendCode, page: () => SendCodePage(), binding: SendCodeBinding()),
    */
    // contact page
    GetPage(name: AppRoutes.Contact, page: () => const ContactPage(), binding: ContactBinding()),

  //Message page

    GetPage(name: AppRoutes.Message, page: () => const MessagePage(), binding: MessageBinding(),middlewares: [
       RouteAuthMiddleware(priority: 1),
     ],),

    //profile page
    GetPage(name: AppRoutes.Profile, page: () => const ProfilePage(), binding: ProfileBinding()),

    //chat detail
    GetPage(name: AppRoutes.Chat, page: () => const ChatPage(), binding: ChatBinding()),
/*
    GetPage(name: AppRoutes.Photoimgview, page: () => PhotoImgViewPage(), binding: PhotoImgViewBinding()),
   */
    GetPage(name: AppRoutes.VoiceCall, page: () => const VoiceCallPage(), binding: VoiceCallBinding()),
    /*GetPage(name: AppRoutes.VideoCall, page: () => VideoCallPage(), binding: VideoCallBinding()), */
  ];






}
