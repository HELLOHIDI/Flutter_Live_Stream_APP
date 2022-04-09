import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlivestreamapp/models/director_model.dart';
import 'package:flutterlivestreamapp/models/user.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutterlivestreamapp/utils/appId.dart';
import 'package:flutterlivestreamapp/utils/message.dart';
import 'package:flutterlivestreamapp/models/stream.dart';

// StateNotifier : 상태알림 업데이트 기능
// UI를 업데이트하기 위해 청취하는 모든 사용자에게 알림을 보내거나 상태가 변경되었기 때문에 업데이트해야 하는 모든 기능을 알려줌

// 사용하는 것을 멈추면 자체적으로 처분됨.
final directorController = StateNotifierProvider.autoDispose<DirectorController, DirectorModel>((ref) {
  return DirectorController(ref.read);
});

class DirectorController extends StateNotifier<DirectorModel> {
  final Reader read; //제공자 범위 내(main에서 설정한 providerscope)의 모든 상태를 읽을 수 있도록 하는 속성0

  DirectorController(this.read) : super(DirectorModel());

  // 초기화 함수
  Future<void> _initialize() async {
    RtcEngine _engine = await RtcEngine.createWithContext(RtcEngineContext(appId)); // 엔진 생성
    AgoraRtmClient _client = await AgoraRtmClient.createInstance(appId); //클라이언트 생성
    state = DirectorModel(engine: _engine, client: _client); // 디렉터모델 클래스 변수 생성
  }

  Future<void> joinCall({required String channelName, required int uid}) async {
    await _initialize();
    await state.engine?.enableVideo(); // 코어 RTC는 오디오로만 시작, 그래서 비디오를 활성화시킨다.
    await state.engine?.setChannelProfile(ChannelProfile.LiveBroadcasting); //세개의 프로필(생방송, 일반 영상통화, 게임) 중 생방송을 활성화시킨다.
    await state.engine?.setClientRole(ClientRole.Broadcaster); // 2개의 역할(방송자, 시청자) 중 방송자를 활성화 시킨다.

    // Participant.dart 와 유사
    state.engine?.setEventHandler(
      RtcEngineEventHandler(
        //TODO: Add join channel logic
        joinChannelSuccess: (channel, uid, elapsed) {
          print("Director $uid");
        },
        leaveChannel: (stats) {
          print("Channel Left");
        },
        // 참가자를 로비에서 화상채팅방으로
        userJoined: (uid, elapsed) {
          print("USER JOINED " + uid.toString());
          addUserToLobby(uid: uid);
        },

        // 참가자를 오프라인(제거)으로
        userOffline: (uid, reason) {
          removeUser(uid: uid);
        },

        // 음소거 여부를 변경하는 함수
        remoteAudioStateChanged: (uid, state, reason, elapsed) {
          // 해당 사용자의 상태가 unmuted일때
          if (state == AudioRemoteState.Decoding) {
            updateUserAudio(uid: uid, muted: false);
            // 해당 사용자가 상태가 muted일때
          } else if (state == AudioRemoteState.Stopped) {
            updateUserAudio(uid: uid, muted: true);
          }
        },

        // 비디오 활성화 여부를 변경하는 함수
        remoteVideoStateChanged: (uid, state, reason, elapsed) {
          // 해당 사용자의 상태가 videoabled일때
          if (state == VideoRemoteState.Decoding) {
            updateUserVideo(uid: uid, videoDisabled: false);
          }
          // 해당 사용자의 상태가 videodisabled일때
          else if (state == VideoRemoteState.Stopped) {
            updateUserVideo(uid: uid, videoDisabled: true);
          }
        },
      ),
    );

    // Callbacks for RTM Client
    state.client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Private Message from " + peerId + ":" + (message.text));
    };

    state.client?.onConnectionStateChanged = (int st, int reason) {
      print('Connection state changed:  ' + state.toString() + ', reason:  ' + reason.toString());
      if (st == 5) {
        state.channel?.leave();
        state.client?.logout();
        state.client?.destroy();
        print("Logout.");
      }
    };

    //Joined the RTM and RTC channels
    await state.client?.login(null, uid.toString());
    // copywith로 기존것 유지하기
    state = state.copyWith(channel: await state.client?.createChannel(channelName));
    await state.channel?.join();
    await state.engine?.joinChannel(null, channelName, null, uid);

    // Callbacs for RTM Channel
    state.channel?.onMemberJoined = (AgoraRtmMember member) {
      print("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };

    state.channel?.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };

    state.channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      //TODO: implement this
      print("Public Message from " + member.userId + ": " + (message.text));
    };

    //Join the RTM and RTC Channels
    await state.client?.login(null, uid.toString());
    state.channel = await state.client?.createChannel(channelName);
    await state.channel?.join();
    await state.engine?.joinChannel(null, channelName, null, uid);
  }

  // 화상 통화를 종료하는 함수 (participant의 dispose와 기능 비슷)
  Future<void> leaveCall() async {
    state.engine?.leaveChannel();
    state.engine?.destroy();
    state.channel?.leave();
    state.client?.logout();
    state.client?.destroy();
  }

  // 로비에 사용자를 추가하는 함수
  Future<void> addUserToLobby({required int uid}) async {
    var userAttributes = await state.client?.getUserAttributes(uid.toString());
    // 기존 로비 유저에 아고라 유저를 추가한다.
    state = state.copyWith(
      lobbyUsers: {
        ...state.lobbyUsers,
        AgoraUser(
          uid: uid,
          muted: true,
          videoDisabled: true,
          // participant에서 결정된 이름과 랜덤한 색상 배정.
          name: userAttributes?["name"],
          backgroundColor: Color(int.parse(userAttributes?["color"])),
        )
      },
    );
    //참가자가 자신의 화면을 업데이트할 수 있도록 활성 사용자들의 메시지를 보냄
    state.channel!.sendMessage(AgoraRtmMessage.fromText(Message().sendActiveUsers(activeUsers: state.activeUsers)));
  }

  // 화상 통화 활성 사용자로 승격하는 함수
  Future<void> promoteToActiveUser({required int uid}) async {
    Set<AgoraUser> _tempLobby = state.lobbyUsers;
    Color? tempColor;
    String? tempName;

    // 로비 사용자 리스트 반복문을 돌면서
    for (int i = 0; i < _tempLobby.length; i++) {
      // 같은 uid(활성 사용자로 승격하려는 대상)이 있으면
      if (_tempLobby.elementAt(i).uid == uid) {
        tempColor = _tempLobby.elementAt(i).backgroundColor;
        tempName = _tempLobby.elementAt(i).name;
        _tempLobby.remove(_tempLobby.elementAt(i)); // 로비 사용자에서 지운다.
      }
    }

    // 활성 사용자 리스트에 agora user(활성 사용자로 승격하려는 대상을)
    // 기존 활성 사용자에 추가한다.
    // 그리고 그 활성 사용자가 빠진 로비 사용자 리스트도 업데이트 해준다.
    state = state.copyWith(activeUsers: {
      ...state.activeUsers,
      AgoraUser(
        uid: uid,
        backgroundColor: tempColor,
        name: tempName,
      )
    }, lobbyUsers: _tempLobby);

    // 음소거 해제 & 비디오 활성화 => 메세지를 보낸다
    state.channel!.sendMessage(AgoraRtmMessage.fromText("unmute $uid"));
    state.channel!.sendMessage(AgoraRtmMessage.fromText("enable $uid"));
    //참가자가 자신의 화면을 업데이트할 수 있도록 활성 사용자들의 메시지를 보냄
    state.channel!.sendMessage(AgoraRtmMessage.fromText(Message().sendActiveUsers(activeUsers: state.activeUsers)));

    if (state.isLive) {
      updateStream();
    }
  }

  // 사용자를 로비로 강등하는 함수.
  Future<void> demoteToLobbyUser({required int uid}) async {
    Set<AgoraUser> _tempActive = state.lobbyUsers;
    Color? tempColor;
    String? tempName;

    // 화상통화 활성화 사용자 리스트 반복문을 돌면서
    for (int i = 0; i < _tempActive.length; i++) {
      if (_tempActive.elementAt(i).uid == uid) {
        // 같은 uid(로비 사용자로 강등하려는 대상)이 있으면
        tempColor = _tempActive.elementAt(i).backgroundColor;
        tempName = _tempActive.elementAt(i).name;
        _tempActive.remove(_tempActive.elementAt(i)); // 활성 사용자에서 지운다.
      }
    }

    // 로비 사용자 리스트에 agora user(로비 사용자로 강등하려는 대상을)
    // 기존 로비 사용자에 추가한다.
    // 그리고 그 로비 사용자가 빠진 활성 사용자 리스트도 업데이트 해준다.
    state = state.copyWith(lobbyUsers: {
      ...state.lobbyUsers,
      AgoraUser(
        uid: uid,
        backgroundColor: tempColor,
        name: tempName,
        videoDisabled: true,
        muted: true,
      )
    }, activeUsers: _tempActive);

    // 음소거 & 비디오 비활성화 => 메세지를 보낸다
    state.channel!.sendMessage(AgoraRtmMessage.fromText("mute $uid"));
    state.channel!.sendMessage(AgoraRtmMessage.fromText("disable $uid"));
    //참가자가 자신의 화면을 업데이트할 수 있도록 활성 사용자들의 메시지를 보냄
    state.channel!.sendMessage(AgoraRtmMessage.fromText(Message().sendActiveUsers(activeUsers: state.activeUsers)));

    if (state.isLive) {
      updateStream();
    }
  }

  // 로비와 화상통화에서 같이 사용자를 지우는 함수
  Future<void> removeUser({required int uid}) async {
    Set<AgoraUser> _tempActive = state.activeUsers; // 화상 통화 활성화 유저
    Set<AgoraUser> _tempLobby = state.lobbyUsers; // 로비 유저

    // 반복문을 돌면서 같은 uid의 사용자를 제거한다.
    for (int i = 0; i < _tempActive.length; i++) {
      if (_tempActive.elementAt(i).uid == uid) {
        _tempActive.remove(_tempActive.elementAt(i));
      }
    }

    // 반복문을 돌면서 같은 uid의 사용자를 제거한다.
    for (int i = 0; i < _tempLobby.length; i++) {
      if (_tempLobby.elementAt(i).uid == uid) {
        _tempLobby.remove(_tempLobby.elementAt(i));
      }
    }

    // 제거한 사용자의 리스트로 업데이트 한다.
    state = state.copyWith(activeUsers: _tempActive, lobbyUsers: _tempLobby);
    //참가자가 자신의 화면을 업데이트할 수 있도록 활성 사용자들의 메시지를 보냄
    state.channel!.sendMessage(AgoraRtmMessage.fromText(Message().sendActiveUsers(activeUsers: state.activeUsers)));

    if (state.isLive) {
      updateStream();
    }
  }

  // 음소거 활성화 여부를 메세지로 보내는 함수
  // 메세지만 보내면 알아서 상태를 업데이트 한다.
  Future<void> toggleUserAudio({required int index, required bool muted}) async {
    if (muted) {
      //send a message to mute
      state.channel!.sendMessage(AgoraRtmMessage.fromText("unmute ${state.activeUsers.elementAt(index).uid}"));
    } else {
      state.channel!.sendMessage(AgoraRtmMessage.fromText("mute ${state.activeUsers.elementAt(index).uid}"));
    }
  }

  // 비디오 활성화 여부를 메세지로 보내는 함수
  // 메세지만 보내면 알아서 상태를 업데이트 한다.
  Future<void> toggleUserVideo({required int index, required bool enabled}) async {
    if (enabled) {
      //send a message to enabled
      state.channel!.sendMessage(AgoraRtmMessage.fromText("enabled ${state.activeUsers.elementAt(index).uid}"));
    } else {
      //send a message to disabled
      state.channel!.sendMessage(AgoraRtmMessage.fromText("disabled ${state.activeUsers.elementAt(index).uid}"));
    }
  }

  Future<void> updateUserAudio({required int uid, required bool muted}) async {
    //singwhere : test를 만족시키는 단일 요소를 반환한다.
    //https://api.dart.dev/stable/2.16.1/dart-core/Iterable/singleWhere.html
    AgoraUser _tempUser = state.activeUsers.singleWhere((element) => element.uid == uid);
    Set<AgoraUser> _tempSet = state.activeUsers;
    // 음소거 활성화를 바꾼후 다시 활성화 사용자 리스트에 등록한다.
    _tempSet.remove(_tempUser);
    _tempSet.add(_tempUser.copyWith(muted: muted));
    state = state.copyWith(activeUsers: _tempSet);
  }

  Future<void> updateUserVideo({required int uid, required bool videoDisabled}) async {
    AgoraUser _tempUser = state.activeUsers.singleWhere((element) => element.uid == uid);
    Set<AgoraUser> _tempSet = state.activeUsers;
    // 음소거 활성화를 바꾼후 다시 활성화 사용자 리스트에 등록한다.
    _tempSet.remove(_tempUser);
    _tempSet.add(_tempUser.copyWith(videoDisabled: videoDisabled));
    state = state.copyWith(activeUsers: _tempSet);
  }

  Future<void> startStream() async {
    List<TranscodingUser> transcodingUsers = [];
    if (state.activeUsers.isEmpty) {
    } else if (state.activeUsers.length == 1) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 1920, height: 1080, zOrder: 1, alpha: 1));
    } else if (state.activeUsers.length == 2) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 960, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 960, y: 0, width: 960, height: 1080));
    } else if (state.activeUsers.length == 3) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 1080));
    } else if (state.activeUsers.length == 4) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 960, y: 0, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 0, y: 540, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 960, y: 540, width: 960, height: 540));
    } else if (state.activeUsers.length == 5) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 0, y: 540, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 960, y: 540, width: 960, height: 540));
    } else if (state.activeUsers.length == 6) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 0, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 640, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 1280, y: 540, width: 640, height: 540));
    } else if (state.activeUsers.length == 7) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 480, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 960, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 1440, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 0, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 640, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(6).uid, x: 1280, y: 540, width: 640, height: 540));
    } else if (state.activeUsers.length == 8) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 480, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 960, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 1440, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 0, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 480, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(6).uid, x: 960, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(7).uid, x: 1440, y: 540, width: 480, height: 540));
    } else {
      throw ("too many members");
    }

    LiveTranscoding transcoding = LiveTranscoding(
      transcodingUsers,
      width: 1920,
      height: 1080,
    );
    state.engine!.setLiveTranscoding(transcoding);
    for (int i = 0; i < state.destinations.length; i++) {
      print("STREAMING TO: ${state.destinations[i].url}");
      state.engine!.addPublishStreamUrl(state.destinations[i].url, true);
    }

    state = state.copyWith(isLive: true);
  }

  Future<void> updateStream() async {
    List<TranscodingUser> transcodingUsers = [];
    if (state.activeUsers.isEmpty) {
    } else if (state.activeUsers.length == 1) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 1920, height: 1080, zOrder: 1, alpha: 1));
    } else if (state.activeUsers.length == 2) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 960, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 960, y: 0, width: 960, height: 1080));
    } else if (state.activeUsers.length == 3) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 1080));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 1080));
    } else if (state.activeUsers.length == 4) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 960, y: 0, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 0, y: 540, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 960, y: 540, width: 960, height: 540));
    } else if (state.activeUsers.length == 5) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 0, y: 540, width: 960, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 960, y: 540, width: 960, height: 540));
    } else if (state.activeUsers.length == 6) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 640, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 1280, y: 0, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 0, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 640, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 1280, y: 540, width: 640, height: 540));
    } else if (state.activeUsers.length == 7) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 480, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 960, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 1440, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 0, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 640, y: 540, width: 640, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(6).uid, x: 1280, y: 540, width: 640, height: 540));
    } else if (state.activeUsers.length == 8) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(1).uid, x: 480, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(2).uid, x: 960, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(3).uid, x: 1440, y: 0, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(4).uid, x: 0, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(5).uid, x: 480, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(6).uid, x: 960, y: 540, width: 480, height: 540));
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(7).uid, x: 1440, y: 540, width: 480, height: 540));
    } else {
      throw ("too many members");
    }

    LiveTranscoding transcoding = LiveTranscoding(
      transcodingUsers,
      width: 1920,
      height: 1080,
    );
    state.engine!.setLiveTranscoding(transcoding);
  }

  Future<void> endStream() async {
    for (int i = 0; i < state.destinations.length; i++) {
      state.engine!.removePublishStreamUrl(state.destinations[i].url);
    }

    state = state.copyWith(isLive: false);
  }

  Future<void> addPublishDestination(StreamPlatform platform, String url) async {
    if (state.isLive) {
      state.engine!.addPublishStreamUrl(url, true);
    }

    state = state.copyWith(destinations: [
      ...state.destinations,
      StreamDestination(platform: platform, url: url)
    ]);
  }

  Future<void> removePublishDestination(String url) async {
    if (state.isLive) {
      state.engine!.removePublishStreamUrl(url);
    }

    List<StreamDestination> temp = state.destinations;
    for (int i = 0; i < temp.length; i++) {
      if (temp[i].url == url) {
        temp.removeAt(i);
        state = state.copyWith(destinations: temp);
        return;
      }
    }
  }
}
