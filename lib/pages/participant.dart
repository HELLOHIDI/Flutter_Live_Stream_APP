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
  final String channelName;
  final String userName;
  final int uid;
  const Participant({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.uid,
  }) : super(key: key);
  _ParticipantState createState() => _ParticipantState();
}

class _ParticipantState extends State<Participant> {
  List<AgoraUser> _users = [];
  late RtcEngine _engine; //실제화상통화?
  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;
  bool muted = false;
  bool videoDisabled = false;
  bool localUserActive = false;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.destroy();
    _channel?.leave();
    _client?.logout();
    _client?.destroy();
    _users.clear();

    super.dispose();
  }

  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _client = await AgoraRtmClient.createInstance(appId);

    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);

    // Callbacks for the RTC ENGINE
    _engine.setEventHandler(
      RtcEngineEventHandler(
          //TODO: Add join channel logic
          joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          int randomColor = (Random().nextDouble() * 0xFFFFFFFF).toInt();
          Map<String, String> name = {
            'key': 'name',
            'value': widget.userName
          };
          Map<String, String> color = {
            'key': 'color',
            'value': randomColor.toString()
          };
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
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Private Message from " + peerId + ":" + (message.text));
    };

    _client?.onConnectionStateChanged = (int state, int reason) {
      print('Connection state changed:  ' + state.toString() + ', reason:  ' + reason.toString());
      if (state == 5) {
        _channel?.leave();
        _client?.logout();
        _client?.destroy();
        print("Logout.");
      }
    };

    // Callbacs for RTM Channel
    _channel?.onMemberJoined = (AgoraRtmMember member) {
      print("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };

    _channel?.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };

    _channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      //TODO: implement this
      List<String> parsedMessage = message.text.split(" ");
      switch (parsedMessage[0]) {
        case "mute":
          if (parsedMessage[1] == widget.uid.toString()) {
            setState(() {
              muted = true;
            });
            _engine.muteLocalAudioStream(true);
          }
          break;
        case "unmute":
          if (parsedMessage[1] == widget.uid.toString()) {
            setState(() {
              muted = false;
            });
            _engine.muteLocalAudioStream(false);
          }
          break;
        case "disable":
          if (parsedMessage[1] == widget.uid.toString()) {
            setState(() {
              videoDisabled = true;
            });
            _engine.muteLocalVideoStream(true);
          }
          break;
        case "enable":
          if (parsedMessage[1] == widget.uid.toString()) {
            setState(() {
              videoDisabled = false;
            });
            _engine.muteLocalVideoStream(false);
          }
          break;
        case "activeUsers":
          setState(() {
            _users = Message().parseActiveUsers(uids: parsedMessage[1]);
          });
          break;
        default:
      }
      print("Public Message from " + member.userId + ": " + (message.text));
    };

    //Join the RTM and RTC Channels
    await _client?.login(null, widget.uid.toString());
    _channel = await _client?.createChannel(widget.channelName);
    await _channel?.join();
    await _engine.joinChannel(null, widget.channelName, null, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Stack(
          children: [
            _broadcastView(),
            _toolbar()
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

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleVideoDisabled() {
    setState(() {
      videoDisabled = !videoDisabled;
    });
    _engine.muteLocalVideoStream(videoDisabled);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }
}
