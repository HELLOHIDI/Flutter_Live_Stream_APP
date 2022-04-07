import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'director.dart';
import 'participant.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _channelName = TextEditingController();
  final _userName = TextEditingController();
  late int uid;

  @override
  void initState() {
    super.initState();
    getUserUid();
  }

  Future<void> getUserUid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? storedUid = preferences.getInt("localUid");
    if (storedUid != null) {
      //저장된 uid가 있다면
      uid = storedUid; //저장된 uid로 설정하고
      print("storeId"); //storeId를 출력한다.
    } else {
      // 없다면
      //should only happen once, unless they delete the app
      int time = DateTime.now().microsecondsSinceEpoch; // 에폭 이후 현재 날짜와 시간을 밀리초 단위로 가져옵니다.
      uid = int.parse(time.toString().substring(1, time.toString().length - 3)); // 그걸 슬라이싱한다.
      preferences.setInt("localUid", uid); //localUid의 값을 설정해준다.
      print("settingUID: $uid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset("assets/streamer.png"),
            SizedBox(height: 5),
            const Text("Multi Streaming with Friends"),
            const SizedBox(height: 40),
            makeTextFieldLoginBox(_userName, "User Name"),
            const SizedBox(height: 8),
            makeTextFieldLoginBox(_channelName, "Channel Name"),
            // 디렉터방으로 가는 버튼
            TextButton(
              // 카메라와 마이크 기능 허용 여부를 허락받는다.
              onPressed: () async {
                await [
                  Permission.camera,
                  Permission.microphone
                ].request();
                // 참가자방으로 넘어갈때 가져가는 속성들
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Participant(
                      // 참가자 방으로 갈 때 channelName, userName, uid 인자값을 넘겨준다
                      channelName: _channelName.text,
                      userName: _userName.text,
                      uid: uid,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Participant  ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(Icons.live_tv),
                ],
              ),
            ),
            // 디렉터방으로 가는 버튼
            TextButton(
              // 카메라와 마이크 기능 허용 여부를 허락받는다.
              onPressed: () async {
                await [
                  Permission.camera,
                  Permission.microphone
                ].request();
                // 디렉터 방으로 갈 때 channelName, userName, uid 인자값을 넘겨준다
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Director(
                      uid: uid, // uid를 participant 파일로 넘겨준다
                      channelName: _channelName.text,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Director  ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(Icons.cut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeTextFieldLoginBox(TextEditingController controller, String hintText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
