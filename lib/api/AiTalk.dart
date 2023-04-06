import 'dart:convert';
import 'dart:ffi';
import 'package:ai_talk/utils/data_util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AiTalk {
   final MethodChannel _listenChannel = const MethodChannel('my_app/listenChannel');
   final MethodChannel _speakChannel = const MethodChannel('my_app/speakChannel');
   final MethodChannel _stopChannel = const MethodChannel('my_app/stopChannel');

   bool _isListening = false;
   bool canListen = true;

   Future<String>  callListen() async {
    try {
      if(_isListening){
        return 'error';
      }
      _isListening = true;
      String result = await _listenChannel.invokeMethod('openListening', {"arg": "my_argument"});
      DatabaseUtil.db.insert("Chat", {"content": result, "type": 0});
      // 处理成功结果
      _requestOpenAi(result);
      return result;
    } on PlatformException catch (e) {
      // 处理异常
      return 'error';
    }
  }

   Future<void> callStop() async {
     try {
        await _stopChannel.invokeMethod('stop', {"arg": "my_argument"});
       // 处理成功结果
        canListen = false;
     } on PlatformException catch (e) {
       print(e.message);
     }
   }

  Future<String> callSpeak(String text) async {
    try {
      await _speakChannel.invokeMethod('openSpeak', {"arg": text});
      DatabaseUtil.db.insert("Chat", {"content": text, "type": 1});
      _isListening = false;
      if(!text.contains("关闭") && canListen){
        callListen();
      }
      return text;
      // 处理成功结果
    } on PlatformException catch (e) {
      // 处理异常
      return 'error';
    }
  }

  Future<void> _requestOpenAi(String data) async {
    final url = Uri.parse("https://chat-bzl.maybee.shop/api");
    try {
      final response = await http.post(
        url,
        body: json.encode({'messages':[{'role': 'user', 'content': data}],
          'password':'bzl','key':'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',
          'temperature':0.6}),
        headers: {'Content-Type': 'application/json'},
      );
      callSpeak(response.body);
    } catch (error) {
      print('Error: $error');
    }
  }
}
