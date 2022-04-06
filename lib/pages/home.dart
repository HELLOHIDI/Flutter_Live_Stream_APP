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
      uid = storedUid;
      print("storeId");
    } else {
      //should only happen once, unless they delete the app
      int time = DateTime.now().microsecondsSinceEpoch;
      uid = int.parse(time.toString().substring(1, time.toString().length - 3));
      preferences.setInt("localUid", uid);
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
              onPressed: () async {
                await [
                  Permission.camera,
                  Permission.microphone
                ].request();
                // 디렉터방으로 넘어갈때 가져가는 속성들
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Participant(
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
            // 참가자방으로 가는 버튼
            TextButton(
              onPressed: () async {
                await [
                  Permission.camera,
                  Permission.microphone
                ].request();
                // 참가자방으로 넘어갈때 가져가는 속성들
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Director(
                      uid: uid,
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
