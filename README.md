# <a href="">라이브 스트리밍앱 클론 코딩🎥</a>

<!-- 아직 미완성
# Screen
<table>
 <tr>
  <td align='center'></td>
  <td align='center'></td>
 </tr>
 <tr>
  <td><img src=''/></td>
  <td><img src=''/></td>
 </tr>
</table>

<table>
 <tr>
  <td align='center'></td>
  <td align='center'></td>
 </tr>
 <tr>
  <td><img src=''/></td>
  <td><img src='' /></td>
 </tr>
</table>

 <table>
 <tr>
  <td align='center'></td>
 </tr>
 <tr>
  <td><img src=''/></td>
 </tr>
</table>
-->

  
  
# Using Packages
|package|ver.|function|
|---|---|------|
|<a href="https://pub.dev/packages/agora_rtc_engine">agora_rtc_engine</a>|^4.0.7|Agora에서 제공하는 실시간 음성 및 영상 통신을 추가할 수 있는 빌딩 블록을 제공하는 패키지|
|<a href="https://pub.dev/packages/agora_rtm">agora_rtm</a>|^1.0.1|Agora에서 제공하는 실시간 메시징을 추가할 수 있는 빌딩 블록을 제공하는 패키지|
|<a href="https://pub.dev/packages/flutter_riverpod">flutter_riverpod</a>|^0.14.0+3|상태관리를 위한 패키지|
|<a href="https://pub.dev/packages/shared_preferences">shared_preferences</a>|^2.0.8|key-value 형태의 데이터를 디스크에 저장해서 사용할 수 있도록 도와주는 패키지<br>+) 로그인이 필요한 앱을 개발할 때 사용자의 ID와 패스워드 등을 기억하는 기능을 구현할 때 이용 가능|
|<a href="https://pub.dev/packages/app_popup_menu">app_popup_menu</a>|^1.0.0|팝업 메뉴를 제작하도록 도아주는 패키지|
|<a href="https://pub.dev/packages/modal_bottom_sheet">modal_bottom_sheet</a>|^2.0.0|간단하게 바텀시트를 제작하도록 도와주는 패키지|
|<a href="https://pub.dev/packages/circular_menu">circular_menu</a>|^1.2.3|간단하게 애니메이션 원형 메뉴를 제작하도록 도와주는 패키지|
|<a href="https://pub.dev/packages/permission_handler">permission_handler</a>|^8.2.5|사용자에게 여러가지 기능의 권한을 요청하고 상태를 확인할 수 있는 크로스 플랫폼 API를 제공하는 패키지|

# Program Structure
- **📃 main.dart** : 메인 

<h3>📁 models</h3>

  - **📃 direcotr_controller.dart** : 디렉터 스크린을 조종하고 제어하는 파일
      |🛠 함수명|기능|
      |---|---|
      |_initialize|director controller 파일을 시작할 때 초기화하는 함수|
      |joinCall|화상통화에 참여하는 |
      |leaveCall|화상통화를 종료하는 함수|
      |addUserToLobby|로비에 사용자를 추가하는 함수|
      |promoteToActiveUser|로비 사용자를 화상 통화 활성 사용자로 승격시키는 함수|
      |demoteToLobbyUser|화상 통화 활성 사용자를 로비 사용자로 강등시키는 함수|
      |removeUser|로비와 화상통화에서의 사용자를 같이 지우는 함수|
      |toggleUserAudio|음소거 활성화 여부를 메세지로 보내는 함수|
      |toggleUserVideo|비디오 활성황 여부를 메세지로 보내는 함수|
      |updateUserAudio|음소거 활성화 여부를 업데이트 하는 함수|
      |updateUserVideo|비디오 활성화 여부를 업데이트 하는 함수|
      |startStream|라이브 스트리밍을 시작하는 함수|
      |updateStream|라이브 스트리밍을 업데이트 하는 함수|
      |endStream|라이브 스트리밍을 종료하는 함수|
      |addPublishDestination|스트리밍 플랫폼을 추가하는 함수|
      |removePublishDestination|스트리밍 플랫폼을 제거하는 함수|

<h3>📁 models</h3>

  - **📃 direcotr_model.dart** : 디렉터 객체를 모델링하는 파일
      |🔑 속성명|역할|
      |---|---|
      |RtcEngine? engine|video call을 핸들링하는 속성|
      |AgoraRtmClient? client|실시간 메시징을 하는 대상|
      |AgoraRtmChannel? channel|실시간 메시징을 하는 채널|
      |Set<AgoraUser> activeUsers|활성 사용자 유저|
      |Set<AgoraUser> lobbyUsers|로비 사용자 유저|
      |AgoraUser? localUser||
      |bool isLive|라이브 스트리밍 여부|
      |List<StreamDestination> destinations|라이브 스트리밍을 할 플랫폼 리스트|
      
   
   - **📃 stream.dart** : 스트리밍 플랫폼 객체를 모델링하는 파일
      |🔑 속성명|역할|
      |---|---|
      |StreamPlatform platform|라이브 스트리밍 플랫폼|
      |String url|라이브 스트리밍 url|
   
   - **📃 user.dart** : 참가자 객체를 모델링하는 파일
      |🔑 속성명|역할|
      |---|---|
      |int uid|USER ID(이걸 통해서 모든걸 조작한다.)|
      |bool muted|음소거 여부|
      |bool videoDisabled|비디오 활성화 여부|
      |String? name|사용자 프로필 이름|
      |Color? backgroundColor|사용자 프로필 배경색|

<h3>📁 pages</h3>

  - **📃 director.dart** : 관리자 스크린 파일
      - |📦 클래스명|클래스 역할|🔑 속성/역할|
        |---|---|---|
        |StageUser|화상통화 사용자를 관리하는 클래스|**DirectorModel directorData** : director model provider로 현재의 데이터를 얻을 수 있음.<br>**DirectorController directorNotifier** : <br>**int index** : 사용자 인덱스|
        |LobbyUser|로비 사용자를 관리하는 클래스|**DirectorModel directorData** : director model provider로 현재의 데이터를 얻을 수 있음.<br>**DirectorController directorNotifier** : <br>**int index** : 사용자 인덱스|
      
      - |🛠함수명|기능|
        |---|---|
        |initState|관리자 스크린 파일을 시작할 때 초기화 함수|
        |showYoutubeBottomSheet|youtube 라이브 스트리밍을 연결하는 함수|
        |showTwitchBottomSheet|twitch 라이브 스트리밍을 연결하는 함수|
        |streamButton|다른 플랫폼 라이브 스트리밍을 연결하는 함수|

      
  - **📃 home.dart** : 홈 스크린
      - |📦 클래스명|클래스 역할|🔑 속성/역할|
        |---|---|---|
        |_HomeState|홈 스크린 상태관리를 하는 클래스|**final _channelName** : 채널 입력창 <br>**final _userName** : 사용자 이름 입력창<br>**late int uid** : user uid |
        
      
      - |🛠 함수명|기능|
        |---|---|
        |initState|홈 스크린이 시작될 때 초기화 함수|
        |getUserUid|사용자의 uid를 가져오는 함수|
      
  - **📃 participant.dart** : 화상 통화 참가자 스크린
      - |📦 클래스명|클래스 역할|🔑 속성/역할|
        |---|---|---|
        |_ParticipantState|참가자 스크린 상태관리를 하는 클래스|**List<AgoraUser> _users** : 화상 통화 사용자 리스트 <br> **late RtcEngine _engine** : video call을 핸들링하는 변수<br>**AgoraRtmClient? _client** : 실시간 메시징을 하는 대상<br> **AgoraRtmChannel? _channel** : 실시간 메시징을 하는 채널<br> **bool muted** : 음소거 여부<br> **bool videoDisabled** : 화면 재생 여부<br> **bool localUserActive** : 메인 페이지에 있는지 아닌지를 알기 위해 활성 사용자라는 변수<br>|
  
      - |🛠 함수명|기능|
        |---|---|
        |initState|참가자 스크린이 시작될 때 초기화 함수|
        |dispose|다시 시작할 때 새로운 slate을 얻을 수 있도록 모든 영상 통화와 전체 RTM 연결을 처분하는 함수|
        |_toolbar|툴바를 제작하는 함수|
        |_expandedVideoView|비디오를 감싸는 가로 위젯을 제작하는 함수|
        |_broadcastView|비디오를 감싸는 위젯을 제작하는 함수|
        |_getRenderViews|기본 보기 목록을 가져오는 도우미 기능을 제작하는 함수|
        |_onToggleMute|음소거 여부를 결정하는 함수|
        |_onToggleVideoDisabled|비디오 활성화 여부를 결정하는 함수|
        |_onSwitchCamera|카메라 방향을 결정하는 함수|
        |_onCallEnd|화상통화를 종료하는 함수|
<h3>📁 utils</h3>

  - **📃 appId.dart** : appId를 저장하는 파일
      
      
  - **📃 message.dart** : 활성 사용자 목록을 쉽게 보낼 수 있도록 하는 파일
      |🛠 함수명|기능|
      |---|---|
      |sendActiveUsers|활성 사용자의 uid를 string 형으로 보내는 함수|
      |parseActiveUsers|string형의 활성 사용자의 uid를 리스트로 파싱하는 함수|
      

# Key Features
  
<h2>1. Participate 中 initializeAgora() part</h2>
Agora Real-time Messaging API를 사용하기 위해 필요한 엔진과 클라이언트를 연결 구축하는 기능이다.
 
<h3>1-1. participate.dart</h3>
<pre>
<code>
  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId)); --- ①
    _client = await AgoraRtmClient.createInstance(appId); --- ②
    await _engine.enableVideo(); --- ③
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting); --- ④
    await _engine.setClientRole(ClientRole.Broadcaster); --- ⑤
   // Join the RTM and RTC channels --- ⑥
   await _client?.login(null, widget.uid.toString());
   _channel = await _client?.createChannel(widget.channelName);
   await _channel?.join(); // 참여
   await _engine.joinChannel(null, widget.channelName, null, widget.uid);
   
</code>
</pre>


<details>
 <summary> 🔍 자세히 분석하기 </summary>

### ① _engine = await RtcEngine.createWithContext(RtcEngineContext(appId))
    Agora Real-time Messaging API를 사용하기 위한 실제 엔진을 만든다.
    이때 Agore에서 제작된 appID가 필요하다.
    
    
### ② _client = await AgoraRtmClient.createInstance(appId)
    AgoraRtm 클라이언트를 생성한다.
    이때 Agore에서 제작된 appID가 필요하다.

### ③ await _engine.enableVideo()
    코어 RTC는 오디오로만 시작하게 초기화되어있다.
    그래서 비디오를 활성화시키는 코드를 추가했다.
    
### ④ await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting)
    세개의 프로필(생방송, 일반 영상통화, 게임) 중 생방송을 활성화시킨다.
    
### ⑤ await _engine.setClientRole(ClientRole.Broadcaster)
    2개의 역할(방송자, 시청자) 중 방송자를 활성화 시킨다.
    
### ⑥ Join the RTM and RTC channels
    - uid를 통해 로그인 (이때 uid값을 string형으로 전환해줘야된다.)
    - 화상통화를 할 채널을 생성한다.
    - 생성된 채널에 참여하는 callback함수를 호출한다(다시 알아보기)
    - 채널에 참여하는데 이때 Rtm client와 매칭을 하기 위해서 매개변수로 채널명과 uid를 넣어준다.
</details>



-------------------------------------------

<h2>2. 참가자 음성 활성화 기능</h2>
화상 통화에는 음성 활성화, 비디오 활성화, 카메라 방향 전환, 전화 끊기 등 다양한 기능이 있지만
모두 같은 메커니즘으로 움직이기 때문에 음성 활성화 기능을 대표적인 예시로 참가자 화면의 기능을 설명하겠다.<br>

참가자의 음성 활성화 기능을 설정하는 방법은 크게 두가지이다.<br>
첫번째는 참가자 화면에서 직접 버튼을 통해 음성기능 활성화를 조작하는 범이고,<br>
두번째는 디렉터 화면에서 직접 참가자의 음성 기능 활성화 여부를 통제하는 방법이다.



<h3> 2-1. participate.dart 中 _onToggleMute() & _toolbar() part </h3>
<pre>
<code>

class _ParticipantState extends State<participant> {
bool muted = false; // 음소거 여부 --- ①
bool localUserActive = false; //메인 페이지에 있는지 아닌지를 알기 위해 활성 사용자라는 변수 --- ①
...
localUserActive --- ②
   ? RawMaterialButton( --- ②
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
   : SizedBox(), --- ②
...
void _onToggleMute() { 
 setState(() { --- ③
   muted = !muted;
 });
 _engine.muteLocalAudioStream(muted); --- ④
}
</code>
</pre>


<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① bool muted & bool localUserActive
    - bool muted : 음소거 여부를 결정하는 변수 (초기값 = false)
    - bool localUserActive : 해당 사용자가 활성 사용자인지를 알려주는 변수 (초기값 = false)
    
### ② Muted button part
    1. 만약 활성 사용자이라면, 누르면 _onToggleMute함수를 호출하는 버튼을 보여준다.
    2. 아니라면 공백으로 남긴다.
    
### ③ setState muted part
- 제작한 음소거 버튼을 누르면 setState()를 통해 muted 변수의 값을 반대로 변경해준다.  

### ④ _engine.muteLocalAudioStream(muted)
 - 실제로 음소거를 할 수 있도록 RtcEngine 변수에 해당 라이브러리에서 제공하는 함수를 적용한다.
 - invokeMethod를 통해 해당 라이브러리의 메소드를 불러온다 -> 모르는 개념 정리에서 공부하기!
 <pre>
 <code>
 @override
   Future<void> muteLocalAudioStream(bool muted) {
     return _invokeMethod('muteLocalAudioStream', {
       'muted': muted,
     });
   }
 </code>
 </pre>
</details>


<h3> 2-2. director_controller.dart code & participate.dart 中 onMessageReceived() part</h3>
<pre>
<code>
> director_controller.dart
state.channel!.sendMessage(AgoraRtmMessage.fromText("mute $uid")); --- ①
> participate.dart 中 onMessageReceived()
_channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) { 
      List<String> parsedMessage = message.text.split(" "); --- ②
      switch (parsedMessage[0]) { --- ③
        case "mute":
          if (parsedMessage[1] == widget.uid.toString()) { --- ③
            setState(() {
              muted = true;
            });
            _engine.muteLocalAudioStream(true); --- ④
          }
          break;
</code>
</pre>


<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① state.channel!.sendMessage(AgoraRtmMessage.fromText("unmute $uid"))
    디렉터 컨트롤러에서 AgoraRtmChannel 타입 변수 메소드를 사용해서<br>
    해당 명령(mute or unmute)와 uid를 보낸다.

### ② List<String> parsedMessage = message.text.split(" ")
    참가자 측에서 onMessageReceived()함수로 메세지를 받은것이 확인되면
    해당 메세지를 빈칸에 맞추어 파싱해서 명령어와 uid를 구분한 요소의 리스트를 만든다.
    
### ③ switch-case part
     case문을 통해서 명령어(parsedMessage[0]을 확인하고 if문으로 사용자 uid(parsedMessage[1])를
     확인하여 muted의 true/false를 설정해준다.

### ④ _engine.muteLocalAudioStream(muted)
 - 실제로 음소거를 할 수 있도록 RtcEngine 변수에 해당 라이브러리에서 제공하는 함수를 적용한다.
 - invokeMethod를 통해 해당 라이브러리의 메소드를 불러온다 -> 모르는 개념 정리에서 공부하기!
 <pre>
 <code>
 @override
   Future<void> muteLocalAudioStream(bool muted) {
     return _invokeMethod('muteLocalAudioStream', {
       'muted': muted,
     });
   }
 </code>
 </pre>
</details>

---------------------------------------------------------

<h2> 3. 디렉터가 특정 참가자 음성화 활성화 </h2>
디렉터 화면에서는 로비, 활성 사용자들을 확인할 수 있으면, 그 중 특정 사용자들의 음소거, 비디오 활성화 등의 기능을
직접 설정할 수 있다. 다양한 기능 중 음성 활성화 부분을 대표적인 예시로 같은 메커니즘으로 작동되는 기능을 설명하려고 한다.

<h3> 3-1. director.dart 中 build() </h3>
<pre>
<code>
return Consumer( --- ①
      builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
        DirectorController directorNotifier = watch(directorController.notifier); --- ②
        DirectorModel directorData = watch(directorController); --- ③
</code>
</pre>
<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① Consumer
 - provdiver에 응답하거나 provdiver가 업데이트할 때 상태관리 용도로 사용.(모르는 개념에서 자세히 설명 예정)

### ② directorNotifier
 <pre>
 <code>
 final directorController = StateNotifierProvider.autoDispose<DirectorController, DirectorModel>((ref) {
  return DirectorController(ref.read);
});
 </code>
 </pre>
 - StateNotifier은 상태알림 업데이트 기능 UI를 업데이트하기 위해 청취하는 모든 사용자에게 알림을 보내거나 상태가 변경되었기 때문에 업데이트해야 하는 모든 기능을 알려줘야 된다.
 - directorController notifier에 watch 메소드를 사용해서 디렉터 컨트롤러가 재생성된 경우나 변경된 경우 이 공급자의 말을 들으면 공급자/위젯이 재구성될 수 있게 한다.

### ③ directorData
 - 위에 내용과 비슷한 맥락이지만 directorController에만 watch 메소드를 사용함으로써 데이터적인 부분의 상태 변경에만 관여한다.
</details>

<h3> 3-2. director_controller.dart 中 toggleUserAudio() part </h3>
<pre>
<code>
Future<void> toggleUserAudio({required int index, required bool muted}) async {
    if (muted) {
      state.channel!.sendMessage(AgoraRtmMessage.fromText("unmute ${state.activeUsers.elementAt(index).uid}")); --- ①
    } else {
      state.channel!.sendMessage(AgoraRtmMessage.fromText("mute ${state.activeUsers.elementAt(index).uid}"));
    }
  }
  
+) 이해를 위한 추가 코드
=> director_model.dart
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
  
=> director_controller.dart
  state = DirectorModel(engine: _engine, client: _client); // 디렉터모델 클래스 변수 생성
  
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>
### ① AgoraRtmMessage.fromText("unmute ${state.activeUsers.elementAt(index).uid}")
 - 만약 mute라면 버튼을 누름으로써 unmute로 바꿔야 되기 때문에 생성된 해당 활성 사용자의 인덱스(state.activeUsers.elementAt(index))
 를 통해 uid를 구해 unmute 메세지를 보낸다.(Key Features 2번 참고)
</details>

<h3> 3-3. director.dart 中 Mute Button part </h3>
<pre>
<code>
IconButton(
   onPressed: () {
     if (directorData.activeUsers.elementAt(index).muted) { --- ①
       directorNotifier.toggleUserAudio(index: index, muted: true);
     } else {
       directorNotifier.toggleUserAudio(index: index, muted: false);
     }
   },
   icon: Icon(Icons.mic_off),
   color: directorData.activeUsers.elementAt(index).muted ? Colors.red : Colors.white, --- ②
 ),
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① onPressed part
 - 만약 directorData의 해당 활성 사용자가 음소거라면 버튼을 눌러 toggleUserAudio 함수를 호출시켜 음성을 활성화 시킨다.    

### ② color part
 - 만약 muted라면 빨간색, 아니면 하얀색
</details>


---------------------------------------------------------


<h2> 4. 로비 사용자를 활성 사용자로 승격시키는 기능 </h2>
로비에 있는 참가자를 화상 통화 참가자로 자격을 승격시키는 기능이다.

<h3> 4-1. director_controller.dart 中 promoteToActiveUser() </h3>
<pre>
<code>
  Future<void> promoteToActiveUser({required int uid}) async {
    Set<AgoraUser> _tempLobby = state.lobbyUsers;
    Color? tempColor;
    String? tempName;
    for (int i = 0; i < _tempLobby.length; i++) {
      if (_tempLobby.elementAt(i).uid == uid) {
        tempColor = _tempLobby.elementAt(i).backgroundColor;
        tempName = _tempLobby.elementAt(i).name;
        _tempLobby.remove(_tempLobby.elementAt(i));
      } --- ①
    }
    state = state.copyWith(activeUsers: { --- ②
      ...state.activeUsers,
      AgoraUser(
        uid: uid,
        backgroundColor: tempColor,
        name: tempName,
      )
    }, lobbyUsers: _tempLobby);
    state.channel!.sendMessage(AgoraRtmMessage.fromText("unmute $uid")); --- ③
    state.channel!.sendMessage(AgoraRtmMessage.fromText("enable $uid")); --- ③
    state.channel!.sendMessage(AgoraRtmMessage.fromText(Message().sendActiveUsers(activeUsers: state.activeUsers))); --- ③
    if (state.isLive) { 
      updateStream(); --- ④ 
    }
  }
+) director.dart 中 build()
  IconButton( --- ⑤
    onPressed: () {
      directorNotifier.promoteToActiveUser(uid: directorData.lobbyUsers.elementAt(index).uid);
    },
    icon: Icon(Icons.arrow_upward),
    color: Colors.white,
  ),
</code>
</pre>


<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① 로비 사용자 리스트에서 사용자 지우기
    로비유저 리스트를 반복문으로 돌면서 승격하고자 하는 사용자의 uid와 일치하다면,<br>
    tempColor, tempName의 해당 사용자의 색상과 이름을 대입하고<br>
    로비 사용자 리스트에서 해당 사용자를 지운다.
    
### ② 활성 사용자 리스트에 추가하기
    state를 copywith을 통해서 승격하고자 하는 사용자의 값을 스프레드 연산자를 통해<br>
    activeUsers 리스트에 추가하고, lobbyUsers 리스트는 _tempLobby(승격 사용자를 제외한 리스트)로 업데이트 한다.
    
### ③ 음소거 해제 & 비디오 활성화
    추가된 사용자의 음성과 비디오를 활성화 시키고, activeUsers가 바뀜을 메세지로 보낸다.
    
### ④ updateStream()
     라이브 스트리밍 중이면 updateStream()을 통해 업데이트 해준다.
     
### ⑤ promotebutton
     디렉터 화면에서 아이콘 버튼을 누름으로써 promoteToActiveUserg 함수를 호출하여 로비 사용자를 승격시킬 수 있다.
 </code>
 </pre>
</details>

----------------------------------------------------------

<h2> 5. 라이브 스트리밍 기능 활성화 </h2>
해당 화상 통화를 다양한 플랫폼을 통해서 라이브 스트리밍을 할 수 있다. 대표적으로는 youtube, twitch가 있다.

<h3> 5-1. stream.dart </h3>
<pre>
<code>
enum StreamPlatform { youtube, twitch, other } --- ① 

class StreamDestination {
  StreamPlatform platform; --- ②
  String url; --- ②

  StreamDestination({
    required this.platform,
    required this.url,
  });
}

</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① enum StreamPlatform { youtube, twitch, other }
    사용할 플랫폼을 enum을 사용하여 StreamPlatform 속성의 상수값을 선언한다
### ② Stream class 속성
    - StreamPlatform platform: 플랫폼
    - String url: 해당 url
</details>


<h3> 5-2. director_controller.dart 中 addPublishDestination() & removePublishDestination  </h3>
<pre>
<code>
  Future<void> addPublishDestination(StreamPlatform platform, String url) async {
    if (state.isLive) {
      state.engine!.addPublishStreamUrl(url, true); --- ① 
    }
    state = state.copyWith(destinations: [ --- ② 
      ...state.destinations,
      StreamDestination(platform: platform, url: url)
    ]);
  }
  Future<void> removePublishDestination(String url) async {
    if (state.isLive) { --- ③
      state.engine!.removePublishStreamUrl(url);
    }
    List<StreamDestination> temp = state.destinations; --- ④
    for (int i = 0; i < temp.length; i++) {
      if (temp[i].url == url) {
        temp.removeAt(i);
        state = state.copyWith(destinations: temp);
        return;
      }
    }
  }
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① state.engine!.addPublishStreamUrl(url, true)
    Agora Real-time Messaging 엔진에서 제공하는 addPublishStreamUrl()을 통해
    스트리밍 플랫폼을 추가한다.
    
    <pre>
    <code>
    @override
    Future<void> addPublishStreamUrl(String url, bool transcodingEnabled) {
      return _invokeMethod('addPublishStreamUrl', {
        'url': url,
        'transcodingEnabled': transcodingEnabled,
      });
    }
    </code>
    </pre>
    
### ② update platform
    state를 copywith을 통해서 추가한 플랫폼을 스프레드 연산자를 통해<br>
    destinations 리스트에 추가하여 합병한다.
    
### ③ state.engine!.removePublishStreamUrl(url)
     Agora Real-time Messaging 엔진에서 제공하는 addPublishStreamUrl()을 통해
    스트리밍 플랫폼을 제거한다.

### ④ delete platform
    반복문을 돌면서 삭제할 플랫폼을 찾은 후 state를 삭제 한 뒤 플랫폼 리스트로 업데이트한다.
</details>


<h3> 5-3. director_controller.dart 中 startStream() & endStream() </h3>
<pre>
<code>
Future<void> startStream() async {
    List<TranscodingUser> transcodingUsers = []; --- ①
    if (state.activeUsers.isEmpty) { 
    } else if (state.activeUsers.length == 1) {
      transcodingUsers.add(TranscodingUser(state.activeUsers.elementAt(0).uid, x: 0, y: 0, width: 1920, height: 1080, zOrder: 1, alpha: 1)); --- ①
      ...
      LiveTranscoding transcoding = LiveTranscoding( --- ②
      transcodingUsers,
      width: 1920,
      height: 1080,
    );
    state.engine!.setLiveTranscoding(transcoding); --- ②
    for (int i = 0; i < state.destinations.length; i++) { --- ③
      print("STREAMING TO: ${state.destinations[i].url}");
      state.engine!.addPublishStreamUrl(state.destinations[i].url, true);
    }
    state = state.copyWith(isLive: true); --- ⑤
  }
  Future<void> endStream() async {
    for (int i = 0; i < state.destinations.length; i++) {
      state.engine!.removePublishStreamUrl(state.destinations[i].url); --- ④
    }
    state = state.copyWith(isLive: false); --- ⑤
  }
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① List<TranscodingUser> transcodingUsers
    트랜스코딩을 위한 변수를 제작하고 만약 활성 사용자가 있따면 트랜스코딩을 한다.<br>
    (트랜스코딩은 모르는 개념정리에서 정리할 예정)
    
### ② LiveTranscoding transcoding
    Agora Real-time Messaging 엔진에서 제공하는 setLiveTranscoding()을 통해 트랜스코딩을 한다.
    그 후 등록된 플랫폼에 순서대로 라이브 스트리밍을 순차적으로 시작한다.

### ④ state.engine!.removePublishStreamUrl(state.destinations[i].url)
    Agora Real-time Messaging 엔진에서 제공하는 removePublishStreamUrl()을 통해<br>
    등록된 플랫폼에 순서대로 라이브 스트리밍을 순차적으로 종료한다.
    
### ⑤ state.copyWith(isLive: true / false)
    라이브 스트리밍을 시작하거나 끝날 때 isLive 속성을 copyWith 메서드를 통해서 업데이트 해준다.
</details>


<h3> 5-4. director.dart 中 showTwitchBottomSheet() & streamButton() </h3>
<pre>
<code>
Future<dynamic> showTwitchBottomSheet(BuildContext context, DirectorController directorNotifier) {
    TextEditingController streamUrl = TextEditingController(); --- ①
    TextEditingController streamKey = TextEditingController(); --- ①
    return showModalBottomSheet( --- ② 
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...
              TextField( --- ①
                autofocus: true,
                controller: streamUrl,
                decoration: InputDecoration(hintText: "Injest Url"),
              ),
              TextField( --- ①
                controller: streamKey,
                decoration: InputDecoration(hintText: "Stream Key"),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton( --- ②
                      onPressed: () {
                        directorNotifier.addPublishDestination(StreamPlatform.twitch, "rtmp://" + streamUrl.text.trim() + "/app/" + streamKey.text.trim());
                        Navigator.pop(context);
                      },
                      child: Text("Add"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget streamButton(StreamDestination destination) { --- ③
    switch (destination.platform) {
      case StreamPlatform.youtube:
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
          child: Text(
            "Youtube",
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.all(8),
          margin: const EdgeInsets.only(right: 4),
        );
    }
  }
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① streamUrl & streamKey
    라이브 스트리밍을 위해 필요한 url과 key가 들어갈 입력창이며,<br>
    RTMP를 넣어주는 과정이다.(RTMP는 모르는 개념 정리에서 정리할 예정)
    
### ② showModalBottomSheet & ElevatedButton
    해당 버튼을 누르면 directorcontroller의 addPublishDestination() 함수를 호출하여 플랫폼을 등록한다.<br>
    이때 url에 해당되는 인자는 각 플랫폼의 형식에 맞추어서 대입한다.
    
### ③ streamButton
    각각 플랫폼의 해당되는 버튼을 제작하며, 나중에 스트리밍을 종료할 때 사용된다.
</details>


<h3> 5-5. director.dart 中 PopupMenuButton() </h3>
<pre>
<code>
PopupMenuButton(
      itemBuilder: (context) {
        List<PopupMenuEntry<Object>> list = [];
        list.add( --- ①
          makePopMenuItem(
            "Youtube",
            StreamPlatform.youtube,
          ),
        );
        list.add(const PopupMenuDivider());
        ...
        return list;
      },
      icon: Icon(Icons.add),
      onCanceled: () {
        print("You have canceld menu");
      },
      onSelected: (value) { --- ①
        switch (value) {
          case StreamPlatform.youtube:
            showYoutubeBottomSheet(context, directorNotifier);
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    for (int i = 0; i < directorData.destinations.length; i++)
      PopupMenuButton( --- ②
        itemBuilder: (context) { 
          List<PopupMenuEntry<Object>> list = [];
          list.add(
            const PopupMenuItem(child: ListTile(leading: Icon(Icons.remove), title: Text("Remove Stream")), value: 0),
          );
          return list;
        },
        child: streamButton(directorData.destinations[i]), --- ③
        onCanceled: () {
          print("You have canceled the menu");
        },
        onSelected: (value) {
          directorNotifier.removePublishDestination(directorData.destinations[i].url);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① makePopMenuItem & onSelected button
    팝메뉴 아이템에 플랫폼 아이템을 추가하고, 해당 아이템을 누르면 각각의 showBottomSheet() 함수를 호출한다.
    
### ② PopupMenuButton
    스트리밍을 종료하는 아이템을 만든다.

### ③ removePlatform
    streambutton 중 해당 플렛폼을 누르며 removePublishDestination()을 호출하여 종료시킨다.
</details>


<h3> 5-6. director.dart 中 build() </h3>
<pre>
<code>
directorData.isLive
     ? CircularMenuItem( --- ①
         icon: Icons.cancel,
         color: Colors.orange,
         onTap: () {
           directorNotifier.endStream();
         },
       )
       : CircularMenuItem( --- ②
         icon: Icons.videocam,
         color: Colors.orange,
         onTap: () {
           if (directorData.destinations.isNotEmpty) {
             directorNotifier.startStream();
           } else {
             throw ("Invalid URL");
           }
         },
       ),
</code>
</pre>

<details>
<summary> 🔍 자세히 분석하기 </summary>

### ① isLive Button
    라이브 스트리밍 중일때 버튼을 누르면 스트리밍을 종료한다.
    
### ② !isLive Button
    라이브 스트리밍 중이 아닐 때 만약 destination이 비어있지 않으면 리스트에 등록되어 있는<br>
    플랫폼으로 스트리밍을 시작하고 아니면 에러를 던진다.
    
</details>

<!---- 아직 완성 x 
---------------------------------------------------------

<h2>❓ 모르는 개념 정리</h2>
<details>
<summary> 🔍 자세히 알아보기! </summary>
 #### 1. Method channel
 
 #### 2. provider
 
 #### 3.  RTMP
 https://ko.wikipedia.org/wiki/%EB%A6%AC%EC%96%BC_%ED%83%80%EC%9E%84_%EB%A9%94%EC%8B%9C%EC%A7%95_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C

 #### 4. 트렌스코딩
   // 새로 추가할 url을 추가하고, transcoding 여부를 true로 한다.
      // https://blog.naver.com/PostView.naver?blogId=dna2073&logNo=221111113511&redirect=Dlog&widgetTypeCall=true&directAccess=false
      // transcoding : 재생하는 디바이스(디바이스=재생장치=스마트폰, PC)가
      // 영상의 코덱을 지원할지 못할때..   실시간으로 인코딩을 하여 재생이  가능하도록 해주는것
 
 #### 5. copywith 메소드 (model 파일)

 #### 6. singwhere (https://api.dart.dev/stable/2.16.1/dart-core/Iterable/singleWhere.html)
 
 #### 7. 
 #### 8. 
 </details>
--->
# 기술 스택 (Technique Used)

<table>
 <tr>
  <td align='center'><img src='https://user-images.githubusercontent.com/40621030/136700782-179675b0-9bae-4ecf-b94a-e73073d24be5.png' height=80></a></td>
  <td align='center'><img src='https://user-images.githubusercontent.com/19565940/137632602-01a7fc0f-00af-49af-bc96-8aee25b83a9d.png' height=80></a></td>
  <td align='center'><img src='https://user-images.githubusercontent.com/19565940/137632657-bf613560-c27e-4dcf-b229-024230185e3b.png' height=80></td>
  <td align='center'><img src='https://user-images.githubusercontent.com/54922625/161429853-4ea674bd-79cb-4fae-9664-b11713922a77.png' height=80></td>
  
  
 </tr>
 <tr>
  <td align='center'>Flutter</td>
  <td align='center'>Libraries from pub.dev</td>
  <td align='center'>Dart</td>
  <td align='center'>agora</td>
 </tr>
</table>

<!--아직 미완성
# 배운점
- stream에 대해서 더욱 자세히 공부해보자
- 나태해진 탓에 몇 달에 걸려서 고작 한개밖에 완성하지 못했다. 그래도 문서화까지 시키면서
  완성을 시켜서 기분이 좋다! 이번 기회로 꾸준히 공부해야겠다.
- firebase를 처음으로 사용해봤는데, firebase와 flutter을 같이 활용할 수 있는 프로젝트를
  많이 시도해야겠다.

# 참고 사이트
https://www.kowanas.com/coding/2021/01/25/methodchannel/ <method channel>

<provider>
https://terry1213.github.io/flutter/flutter-provider/
https://eunjin3786.tistory.com/255

--->

