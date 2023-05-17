import 'package:chatty/common/values/colors.dart';
import 'package:chatty/pages/frame/welcome/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({Key? key}) : super(key: key);

Widget _buuildLogo(){
  return Container(
    margin: EdgeInsets.only(top: 100.h, bottom: 80.h),
    child: Text(
      "Chatty .",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.primaryText,
        fontSize: 35.sp,
        fontWeight: FontWeight.bold,

      ),
    ),



  );
}
Widget _buildThirdPartyLogin(String logintype, String logo){
  return GestureDetector(
    child: Container(
      width: 295.w,
      height: 44.h,
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0,1)
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 40.w, right: 30.w),
            child: Image.asset("assets/icons/${logo}.png"),
          ),
          Container(
            child:  Text(
              "Sign in with $logintype",
            textAlign: TextAlign.center,
              style: TextStyle(
              color: AppColors.primaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
              ),
            ),
          )
        ],
      ),
    ),
    onTap: (){
      print("SIGN IN WITH ${logintype}");
      controller.handleSignIn("google");
      print("SIGN IN WITH ......");

    },
  );
}
Widget _buildOrWidget(){
  return Container(
    margin: EdgeInsets.only(top: 20.h, bottom: 35.h),
    child: Row(
      children: [
        Expanded(
          child: Divider(
            indent: 50,
            height: 2.h,
            color: AppColors.primarySecondaryElementText,
          ),
        ),
        const Text("   or   "),
        Expanded(
          child: Divider(
            endIndent: 50,
            height: 2.h,
            color: AppColors.primarySecondaryElementText,
          ),
        ),
      ],
    ),
  );
}
Widget _buildSignInWidget(){
  return GestureDetector(
    child: Column(
      children: [
        Text(
          "Already have an account?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        GestureDetector(
          child: Text(
            "Sign in here",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryElement,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        )
      ],
    ),
    onTap: (){
      print("SIGN IN FROM HERE");

    },
  );
}


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.primarySecondaryBackground,
      body: Center(
       child: Center(
         child: Column(
           children: [
             _buuildLogo(),
             _buildThirdPartyLogin("Google", "google"),
             _buildThirdPartyLogin("Facebook","facebook"),
             _buildThirdPartyLogin("Apple","apple"),
             _buildOrWidget(),
             _buildThirdPartyLogin("phone number","phone"),
             SizedBox(height: 35.h,),
             _buildSignInWidget(),


             ],
         )
       ),
      ),

    );
  }
}
