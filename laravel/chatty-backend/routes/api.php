<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


Route::group(['namespace'=>'Api'], function(){
    Route::any('/login', 'LoginController@login');
   Route::any('/contact', 'LoginController@contact')->middleware('CheckUser');
   Route::any('/get_rtc_token', 'AccessTokenController@get_rtc_token')->middleware('CheckUser');
   Route::any('/send_notice','LoginController@send_notice')->middleware('CheckUser');
   Route::any('/bind_fcmtoken','LoginController@bind_fcmtoken')->middleware('CheckUser');
   Route::any('/upload_photo','LoginController@upload_photo')->middleware('CheckUser');
});