import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutterlivestreamapp/models/user.dart';
import 'package:flutterlivestreamapp/models/stream.dart';

// 추적될 데이터 조각
class DirectorModel {
  RtcEngine? engine; //video call을 핸들링하는 속성
  AgoraRtmClient? client; // 실시간 메시징을 하는 대상
  AgoraRtmChannel? channel; // 실시간 메시징을 하는 채널
  Set<AgoraUser> activeUsers; // 활성 사용자 유저
  Set<AgoraUser> lobbyUsers; // 로비 사용자 유저
  AgoraUser? localUser;
  bool isLive; // 라이브 스트리밍 여부
  List<StreamDestination> destinations; // 라이브 스트리밍을 할 플랫폼 리스트

  // 생성자
  DirectorModel({
    this.engine,
    this.client,
    this.channel,
    this.activeUsers = const {},
    this.lobbyUsers = const {},
    this.localUser,
    this.isLive = false,
    this.destinations = const [],
  });

  // https://sudarlife.tistory.com/entry/%ED%94%8C%EB%9F%AC%ED%84%B0-immutable-VS-mutable-%EA%B8%B0%EB%B3%B8%EC%9D%B4%EC%A7%80%EB%A7%8C-%ED%97%B7%EA%B0%88%EB%A6%B4-%EC%88%98-%EC%9E%88%EB%8A%94-%EA%B0%9C%EB%85%90-%EC%9E%A1%EA%B3%A0-%EA%B0%80%EC%8B%A4%EA%BB%98%EC%9A%94
  // class는 메모리 누수를 방지하고자 기본적으로 mutable로 설계
  // 새로운 객체로 데이터를 copy 해서 넘겨줘야 한다는 소리
  // 새로운 객체를 만들고 데이터를 옮겨 주거나 , 기존의 User 객체에 copy 메서드를 만들어서 변경한 데이터만 바꿔서 새로 만들어 넘겨주는 방식을 사용하면 됩니다. 이러한 방식이 방어적인 대응

  // => 이렇게 하면 개체 내에서 한 가지를 변경할 수 있지만 개체는 여전히 남아 있습니다.
  DirectorModel copyWith({
    RtcEngine? engine,
    AgoraRtmClient? client,
    AgoraRtmChannel? channel,
    Set<AgoraUser>? activeUsers,
    Set<AgoraUser>? lobbyUsers,
    AgoraUser? localUser,
    bool? isLive,
    List<StreamDestination>? destinations,
  }) {
    return DirectorModel(
      engine: engine ?? this.engine,
      client: client ?? this.client,
      channel: channel ?? this.channel,
      activeUsers: activeUsers ?? this.activeUsers,
      lobbyUsers: lobbyUsers ?? this.lobbyUsers,
      localUser: localUser ?? this.localUser,
      isLive: isLive ?? this.isLive,
    );
  }
}
