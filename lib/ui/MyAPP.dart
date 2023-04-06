import 'package:ai_talk/api/AiTalk.dart';
import 'package:ai_talk/utils/data_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Speech to Text Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  List<Map<String, dynamic>> items = [
    {'content': '你好', 'type': 1}
  ];
  AiTalk aiTalk = AiTalk();

  @override
  void initState() {
    super.initState();
    DatabaseUtil.db.queryAllRows("chat").then((value) => {
          setState(() {
            items = value;
          })
        });
  }

  void _callListen() async {
    try {
      aiTalk.canListen = true;
      String result = await aiTalk.callListen();
      // 处理成功结果
      print(result);
    } on PlatformException catch (e) {
      // 处理异常
      print('error');
    }
  }

  void _stop() {
    aiTalk.callStop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Demo'),
      ),
      body: Column(
        children: [
          SizedBox(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  switch (item["type"]) {
                    case 0:
                      return ListTile(
                        title: Text(item["content"]),
                        tileColor: Colors.green,
                      );
                    case 1:
                      return ListTile(
                        title: Text(item["content"]),
                        tileColor: Colors.red,
                      );
                    default:
                      return Container();
                  }
                },
              ),
              height: 500),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: const Icon(Icons.mic),
                  onPressed: _callListen,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  child: const Icon(Icons.stop),
                  onPressed: _stop,
                ),
              ],
            ),
            height: 80,
          )
        ],
      ),
    );
  }
}
