import 'dart:io';

import 'package:chatty/common/entities/entities.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/values/colors.dart';
import 'package:chatty/common/widgets/toast.dart';
import 'package:chatty/pages/message/chat/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/apis/chat.dart';

class ChatController extends GetxController{
  ChatController();





  final state=ChatState();
  late String doc_id;
  final myInputController = TextEditingController();
  final token = UserStore.to.profile.token;

  //firebase db instance
  final db = FirebaseFirestore.instance;
  var listener;
  var isLoadmore = true;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  ScrollController myScrollController = ScrollController();

  void goMore(){
    state.more_status.value = state.more_status.value?false:true;
  }
  void audioCall(){
    state.more_status.value = false;
    Get.toNamed(AppRoutes.VoiceCall,
      parameters: {
      "to_token": state.to_token.value,
      "to_name": state.to_name.value,
      "to_avatar": state.to_avatar.value,
        "call_role": "anchor",
        "doc_id": doc_id

      }
    );
  }

@override
  void onInit(){
  super.onInit();
  var data = Get.parameters;
  print(data);
  doc_id = data['doc_id']!;
  state.to_token.value = data['to_token']??"";
  state.to_name.value = data['to_name']??"";
  state.to_avatar.value = data['to_avatar']??"";
  state.to_online.value = data['to_online']??"1";


}
@override
void onReady(){
    super.onReady();
    state.msgcontentList.clear();
    final messages = db.collection("message").doc(doc_id).collection("msglist").withConverter(
        fromFirestore: Msgcontent.fromFirestore, toFirestore: (Msgcontent msg, options)=>msg.toFirestore())
    .orderBy("addtime", descending: true).limit(15);

    listener = messages.snapshots().listen((event) {
      List<Msgcontent> tempMsgList = <Msgcontent>[];
      for(var change in event.docChanges){
        switch(change.type){

          case DocumentChangeType.added:
            // TODO: Handle this case.
          if(change.doc.data()!=null){
            tempMsgList.add(change.doc.data()!);
            print("${change.doc.data()!}");
            print("...newly added: ${myInputController.text}");
          }
            break;
          case DocumentChangeType.modified:
            // TODO: Handle this case.

            break;
          case DocumentChangeType.removed:
            // TODO: Handle this case.
            break;
        }
      }
      tempMsgList.reversed.forEach((element) {
        state.msgcontentList.value.insert(0, element);
      }
      );
      state.msgcontentList.refresh();

      if(myScrollController.hasClients){
        myScrollController.animateTo(myScrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    myScrollController.addListener(() {
      if(myScrollController.offset+10>myScrollController.position.maxScrollExtent){
        if(isLoadmore){
          state.isloading.value = true;
          isLoadmore = false;
          asyncLoadMoreData();
        }
      }
    });
}
Future imgFromGallery() async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      _photo = File(pickedFile.path);
      print("File picked");
      print("File path $_photo");
      uploadFile();

    }
    else{
      print("..No image selected...");
    }
}
Future uploadFile() async{
  await Permission.mediaLibrary.request();

    var result = await ChatAPI.upload_img(file: _photo);
    print(result.data);
    if(result.code == 0){
      sendImageMessage(result.data!);
    }else{
      toastInfo(msg: "Error in sending image");
    }
}

Future<void> asyncLoadMoreData() async {
    final messages = await db.collection("message")
        .doc(doc_id).collection("msglist")
        .withConverter(fromFirestore: Msgcontent.fromFirestore, toFirestore: (Msgcontent msg, options)=>msg.toFirestore())
    .orderBy("addtime", descending: true).where('addtime',  isLessThan: state.msgcontentList.value.last.addtime).
  limit(10).get();
    if(messages.docs.isNotEmpty){
      messages.docs.forEach((element) {
        var data = element.data();
        state.msgcontentList.value.add(data);
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      isLoadmore = true;
    });
    state.isloading.value = false;
}

Future<void> sendMessage() async {
    var list = await db.collection("message").doc(doc_id).collection("msglist").get(
    );
   String sendContent = myInputController.text;
   // print(sendContent);
   if(sendContent.isEmpty){
     toastInfo(msg: "Can't send empty message",
     backgroundColor: AppColors.primaryElement);
     return;
   }
   // object created to send msg to firebase
   final content = Msgcontent(
     token: token,
     content: sendContent,
     type: "text",
     addtime: Timestamp.now()
   );
   await db.collection("message").doc(doc_id).collection("msglist").
   withConverter(fromFirestore: Msgcontent.fromFirestore, toFirestore: (Msgcontent msg, options)=>msg.toFirestore()
   ).add(content).then((DocumentReference doc) {
     //print("....New msg doc id is $doc_id");
     myInputController.clear();
   });
   /*var list = await db.collection("message").get();
   print(list.docs.length);
   print(list.docs);*/
  var messageResult = await db.collection("message").doc(doc_id).withConverter(
      fromFirestore: Msg.fromFirestore,
      toFirestore: (Msg msg, options)=>msg.toFirestore()).get();
  
  //to keep the count of unread calls and messages
  if(messageResult.data()!=null){
    var item = messageResult.data()!;
    int to_msg_num = item.to_msg_num==null?0:item.to_msg_num!;
    int from_msg_num = item.from_msg_num==null?0:item.from_msg_num!;
    if(item.from_token == token){
      from_msg_num = from_msg_num+1;
    }
    else{
      to_msg_num = to_msg_num+1;
    }
    await db.collection("message").doc(doc_id).update({
      "to_msg_num": to_msg_num,
      "from_msg_num": from_msg_num,
      "last_msg":sendContent,
      "last_time":Timestamp.now()

    });
  }

}

  Future<void> sendImageMessage(String url) async {


    // object created to send img to firebase
    final content = Msgcontent(
        token: token,
        content: url,
        type: "image",
        addtime: Timestamp.now()
    );

    await db.collection("message").doc(doc_id).collection("msglist").
    withConverter(fromFirestore: Msgcontent.fromFirestore, toFirestore: (Msgcontent msg, options)=>msg.toFirestore()
    ).add(content).then((DocumentReference doc) {
      print("....New img doc id is $doc_id");

    });
    /*var list = await db.collection("message").get();
   print(list.docs.length);
   print(list.docs);*/

    var messageResult = await db.collection("message").doc(doc_id).withConverter(
        fromFirestore: Msg.fromFirestore,
        toFirestore: (Msg msg, options)=>msg.toFirestore()).get();

    //to keep the count of unread calls and messages
    if(messageResult.data()!=null){
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num==null?0:item.to_msg_num!;
      int from_msg_num = item.from_msg_num==null?0:item.from_msg_num!;
      if(item.from_token == token){
        from_msg_num = from_msg_num+1;
      }
      else{
        to_msg_num = to_msg_num+1;
      }
      await db.collection("message").doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg":"【image】 ",
        "last_time":Timestamp.now()

      });
    }

  }

  void closeAllPop() async{
    Get.focusScope?.unfocus();
    state.more_status.value = false;

}
@override

  void onClose(){
    super.onClose();
    listener.cancel();
    myInputController.dispose();
    myScrollController.dispose();
}
}