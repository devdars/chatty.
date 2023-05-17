<?php

namespace App\Http\Controllers\Api;
use Exception;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Laravel\Firebase\Facades\Firebase;

class LoginController extends Controller{

public function login(Request $request){

        $validator = Validator::make($request->all(), [
            'avatar'=>'required',
            'name'=>'required',
            'type'=>'required',
            'open_id'=>'required',
            'email'=>'max:50',
            'phone'=>'max:30',
            
            


        ]);

        if($validator->fails())
        {
            return['code'=>-1, "data"=>"no valid data", '$msg'=>$validator->errors()->first()] ;



        }
        try{

            $validated =$validator->validated();
            $map =[];
            $map['type'] = $validated['type'];
            $map['open_id'] = $validated['open_id'];
            $result=DB::table('users')->select('avatar', 'name', 'description', 'type', 'token','access_token', 'online')->where($map)->first();
            if(empty($result)){
                $validated['token'] = md5(uniqid().rand(10000, 99999));
                $validated['created_at'] = Carbon::now();
                $validated['access_token'] = md5(uniqid().rand(1000000, 9999999));
                $validated['expire_date'] = Carbon::now()->addDays(30);
                $user_id = DB::table('users')->insertGetId($validated);
                $user_result = DB::table('users')->select('avatar', 'name', 'description', 'type', 'token', 'access_token', 'online')->where('id', '=', $user_id )->first();
                if(empty($result))
    
                return['code'=>0, 'data'=>$user_result, 'msg'=> 'user has been created'];
            }
    else{
        $access_token = md5(uniqid().rand(1000000, 9999999));
        $expire_date = Carbon::now()->addDays(30);
        DB::table('users')->where($map)->update(
            [
                "access_token"=>$access_token,
                "expire_date"=>$expire_date
            ]
    
        );
    
        $result->access_token= $access_token;
        return['code'=>0, 'data'=>$result, 'msg'=> 'user info updated'];
    }



        }
        catch(Exception $e){

            return['code'=>-1, 'data'=>"no data available", 'msg'=> (string)$e];
    }
}
    public function contact(Request $request){
        $token = $request->user_token;
        $res = DB::table("users")->select(
            "avatar",
            "description",
            "online",
            "token",
            "name"
        )->where("token", '!=', $token)->get();

        return['code'=>0, 'data'=>$res, 'msg'=> 'got user info'];



   
        }
        public function send_notice(Request $request){
            //caller info
            $user_token = $request->user_token;
            $user_avatar = $request->user_avatar;
            $user_name = $request->user_name;

            //callee info
            $to_token = $request->input("to_token");
            $to_avatar = $request->input("to_avatar");
            $to_name = $request->input("to_name");
            $call_type = $request->input("call_type");
            $doc_id = $request->input("doc_id");
            if(empty($doc_id)){
                $doc_id="";
            }

            //get the other user info
            $res =DB::table("users")->select("avatar", "name", "token", "fcmtoken")->where("token", "=", $to_token)->first();
            if(empty($res)){
                return['code'=>-1, 'data'=>"", 'msg'=> 'no user exists'];
            }
            $device_token = $res->fcmtoken;
            try{
                if(!empty($device_token)){
                    $messaging = app("firebase.messaging"); //dependency for cloud messaging
                    if($call_type == "cancel"){

                        $message = CloudMessage::fromArray([

                            'token'=>$device_token, //fcm token
                            'data'=>[
                                'token'=>$user_token,
                                'avatar'=>$user_avatar,
                                'name'=>$user_name,
                                'doc_id'=>$doc_id,
                                'call_type'=>$call_type
                            ]
                    

                        ]);
                       
                        $messaging->send($message);

                    }
                    elseif($call_type=="voice")
                    {

                        $message = CloudMessage::fromArray([

                            'token'=>$device_token,
                            'data'=>[
                                'token'=>$user_token,
                                'avatar'=>$user_avatar,
                                'name'=>$user_name,
                                'doc_id'=>$doc_id,
                                'call_type'=>$call_type
                            ],
                            'android'=>[
                                'priority'=>'high',
                                'notification'=>[
                                    'channel_id'=>'com.devans.chatty.message',
                                    'title'=>'Voice call from '. $user_name,
                                    'body'=>'Click to answer the call'
                                ]
                            ]
                    

                        ]);

                    }
                    $messaging->send($message);

                    return['code'=>0, 'data'=>$to_token, 'msg'=> 'success'];

                }else{
                    return['code'=>-1, 'data'=>"", 'msg'=> "device token empty"];
                }


            }
            catch(Exception $e){
                return['code'=>-1, 'data'=>"", 'msg'=> (string)$e];
            }

            


        }
        public function bind_fcmtoken(Request $request){
            $token = $request->user_token;
            $fcmtoken = $request->input("fcmtoken");
            if(empty($fcmtoken)){
                return ["code"=> -1, "data"=>"", "msg"=>"error getting the code"];
            }
          
                DB::table("users")->where('token', '=', $token)->update(['fcmtoken'=>$fcmtoken]);
                return ["code"=> -1, "data"=>"", "msg"=>"success"];
            
        }
        public function upload_photo(Request $request){
            $file = $request->file('file');
            
            try{
               // $extenstion = $file->getClientOriginalExtension(); //png, jpg
                $imageName = uniqid().'.'.$request->file('file')->getClientOriginalExtension();  //doing unique name with extenstion
                $timeDir = date("Ymd");
                $file->storeAs($timeDir, $imageName, ["disk"=>"public"]);
                $url = env("APP_URL")."uploads/".$timeDir.'/'.$imageName;
                return ["code"=>0, "data"=>$url, "msg"=>"success image upload"];
            }/*catch(Exception $e){
                return ["code"=>-1, "data"=>"", "msg"=>"error uploading image"];
            }*/
            catch(\Throwable $th){
                    return ["code"=>-1, "data"=>$th->getMessage(), "msg"=>"error uploading image"];
            }
        }
}

