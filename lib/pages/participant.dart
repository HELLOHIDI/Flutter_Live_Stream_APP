import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
// ignore: library_prefixes
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// ignore: library_prefixes
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutterlivestreamapp/utils/appId.dart';
import 'package:flutterlivestreamapp/models/user.dart';
import 'package:flutterlivestreamapp/utils/message.dart';

class Participant extends StatefulWidget {
  final String channelName; //채널 이름
  final String userName; //사용자 이름
  final int uid; // USER ID(이걸 통해서 모든걸 조작한다.)
  const Participant({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.uid,
  }) : super(key: key);
  _ParticipantState createState() => _ParticipantState();
}

class _ParticipantState extends State<Participant> {
  List<AgoraUser> _users = []; // 화상 통화 사용자 리스트
  late RtcEngine _engine; // video call을 핸들링하는 변수
  AgoraRtmClient? _client; // 실시간 메시징을 하는 대상
  AgoraRtmChannel? _channel; // 실시간 메시징을 하는 채널
  bool muted = false; // 음소거 여부
  bool videoDisabled = false; // 화면 재생 여부
  bool localUserActive = false; //메인 페이지에 있는지 아닌지를 알기 위해 활성 사용자라는 변수
  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  // 모든 영상 통화와 전체 RTM 연결을 처분 => 다시 시작할때 새로운 slate를 얻을 수 있도록!
  @override
  void dispose() {
    _users.clear(); // 참가자 리스트 비우고
    _engine.leaveChannel(); // videocall 채널 떠나고
    _engine.destroy(); // videocall 엔진 파괴
    _channel?.leave(); // rtm 채널 떠나고
    _client?.logout(); // 로그아웃하고
    _client?.destroy(); // rtm 채널 파괴

    super.dispose(); // 전부 처분
  }

  // Agora 프로젝트에 필요한 엔진과 클라이언트를 연결 구축
  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId)); //실제 엔진을 만든다.(gore에서 제작된 appID 필요)
    _client = await AgoraRtmClient.createInstance(appId); //AgoraRtm 클라이언트 생성(gore에서 제작된 appID 필요)

    await _engine.enableVideo(); // 코어 RTC는 오디오로만 시작, 그래서 비디오를 활성화시킨다.
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting); //세개의 프로필(생방송, 일반 영상통화, 게임) 중 생방송을 활성화시킨다.
    await _engine.setClientRole(ClientRole.Broadcaster); // 2개의 역할(방송자, 시청자) 중 방송자를 활성화 시킨다.

    // 이벤트 핸들러 생성
    // 애플리케이션 내에서 어떤 이벤트가 발생할 때마다 트리거될 것이다.
    _engine.setEventHandler(
      RtcEngineEventHandler(
          //채널에 성공적으로 참여하게 되면...
          joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          //_users.add(uid);
          // _users에 등록한다.

          // 활성 사용자마다 랜덤한 배경색을 배정받도록 한다.
          int randomColor = (Random().nextDouble() * 0xFFFFFFFF).toInt();
          Map<String, String> name = {
            'key': 'name',
            'value': widget.userName
          };
          Map<String, String> color = {
            'key': 'color',
            'value': randomColor.toString()
          };
          // 해당 이름과 배경색을 업데이트 해준다.
          _client!.addOrUpdateLocalUserAttributes([
            name,
            color
          ]);
        });
      }, leaveChannel: (stats) {
        setState(() {
          _users.clear();
        });
      }),
    );

    // Callbacks for RTM Client
    // 메세지를 받으면 어떤 클라이언트가 어떤 채널인지를 확인하기 위해 callback 함수를 등록한다.
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Private Message from " + peerId + ":" + (message.text));
    };

    _client?.onConnectionStateChanged = (int state, int reason) {
      // reason : 왜 연결상태가 변하되었는지
      // state : 주어진 현재 상태
      print('Connection state changed:  ' + state.toString() + ', reason:  ' + reason.toString());
      if (state == 5) {
        //연결 상태 중단을 나타내는 값이면(agora api reference)
        _channel?.leave(); // 채널을 떠나고
        _client?.logout(); // 클라이언트는 로그아웃 하고
        _client?.destroy();
        print("Logout."); //로그아웃인것을 프린트 해라
      }
    };

    // Join the RTM and RTC channels
    await _client?.login(null, widget.uid.toString()); // 로그인
    _channel = await _client?.createChannel(widget.channelName); //채널 생성
    await _channel?.join(); // 참여

    // uid가 필요한 이유는 RTM client와 매칭을 해야되기 때문이다.
    await _engine.joinChannel(null, widget.channelName, null, widget.uid); // 채널에 참여한다

    // Callbacs for RTM Channel

    // 멤버가 참여하면 그 멤버의 아이디와 채널을 출력하는 콜백함수
    _channel?.onMemberJoined = (AgoraRtmMember member) {
      print("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };

    // 멤버가 떠나면 그 멤버의 아이디와 채널을 출력하는 콜백함수
    _channel?.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };

    // 채널의 모든 참여자에게 보내는 메세지를 받았을때
    _channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      // 스페이스 기준으로 요소들을 나눔 (ex) mute uid
      List<String> parsedMessage = message.text.split(" ");
      switch (parsedMessage[0]) {
        // mute라면
        case "mute":
          if (parsedMessage[1] == widget.uid.toString()) {
            // 해당 uid의
            // muted 값을 true로 변경하고
            setState(() {
              muted = true;
            });
            // 오디오 스트림을 mute 시킨다
            _engine.muteLocalAudioStream(true);
          }
          break;
        // unmmute라면
        case "unmute":
          if (parsedMessage[1] == widget.uid.toString()) {
            // 해당 uid의
            // muted 값을 false로 변경하고
            setState(() {
              muted = false;
            });
            _engine.muteLocalAudioStream(false);
          }
          break;
        // disable라면
        case "disable":
          if (parsedMessage[1] == widget.uid.toString()) {
            // 해당 uid의
            // videoDisabled 값을 true로 변경하고
            setState(() {
              videoDisabled = true;
            });
            _engine.muteLocalVideoStream(true);
          }
          break;
        // enable라면
        case "enable":
          if (parsedMessage[1] == widget.uid.toString()) {
            // 해당 uid의
            // videoDisabled 값을 false로 변경하고
            setState(() {
              videoDisabled = false;
            });
            _engine.muteLocalVideoStream(false);
          }
          break;
        // activeUsers라면 _users에 추가한다.
        case "activeUsers":
          setState(() {
            _users = Message().parseActiveUsers(uids: parsedMessage[1]);
          });
          break;
        default:
      }
      print("Public Message from " + member.userId + ": " + (message.text));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Stack(
          children: [
            _broadcastView(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          localUserActive
              // 마이크 음소거 여부 버튼
              ? RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              : SizedBox(),
          localUserActive
              // 화상 통화를 종료하는 버튼
              ? RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                )
              : SizedBox(),
          localUserActive
              // 비디오 활성화 여부 버튼
              ? RawMaterialButton(
                  onPressed: _onToggleVideoDisabled,
                  child: Icon(
                    videoDisabled ? Icons.videocam_off : Icons.videocam,
                    color: videoDisabled ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: videoDisabled ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              : const SizedBox(),
          // 카메라 방향 변경 버튼
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Video view row wrapper
  Widget _expandedVideoView(List<Widget> views) {
    final wrappedViews = views.map<Widget>((view) => Expanded(child: Container(child: view))).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _broadcastView() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoView([
              views[0]
            ])
          ],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoView([
              views[0]
            ]),
            _expandedVideoView([
              views[1]
            ])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoView(views.sublist(0, 2)),
            _expandedVideoView(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoView(views.sublist(0, 2)),
            _expandedVideoView(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<Widget> list = [];
    bool checkIfLocalActive = false;
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].uid == widget.uid) {
        list.add(Stack(children: [
          RtcLocalView.SurfaceView(),
          Align(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10)), color: Colors.white),
              child: Text(widget.userName),
            ),
            alignment: Alignment.bottomRight,
          ),
        ]));
        checkIfLocalActive = true;
      } else {
        list.add(Stack(children: [
          RtcRemoteView.SurfaceView(uid: _users[i].uid),
          Align(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10)), color: Colors.white),
              child: Text(_users[i].name ?? "name error"),
            ),
            alignment: Alignment.bottomRight,
          ),
        ]));
      }
    }

    if (checkIfLocalActive) {
      localUserActive = true;
    } else {
      localUserActive = false;
    }
    return list;
  }

  // 음소거 여부를 결정하는 함수
  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  // 비디오 활성화 여부를 결정하는 함수
  void _onToggleVideoDisabled() {
    setState(() {
      videoDisabled = !videoDisabled;
    });
    _engine.muteLocalVideoStream(videoDisabled);
  }

  // 카메라 방향을 결정하는 함수
  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  // 화상통화를 종료하는 함수
  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }
}
