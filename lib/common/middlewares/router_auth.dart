import 'package:flutter/material.dart';
import 'package:chatty/common/routes/routes.dart';
import 'package:chatty/common/store/store.dart';

import 'package:get/get.dart';

/// Check logged in or not
class RouteAuthMiddleware extends GetMiddleware {
  // priority variable smaller the better
  @override
  int? priority = 0;

  RouteAuthMiddleware({required this.priority});

  @override
  RouteSettings? redirect(String? route) {
    if (UserStore.to.isLogin || route == AppRoutes.SIGN_IN || route == AppRoutes.INITIAL
    //|| route == AppRoutes.Message
        )
    {
      return null;
    }
    else
    {
      Future.delayed(
          const Duration(seconds: 2), () => Get.snackbar("LOGIN","Login expired, please login again!"));
      return const RouteSettings(name: AppRoutes.SIGN_IN);
    }
  }
}
