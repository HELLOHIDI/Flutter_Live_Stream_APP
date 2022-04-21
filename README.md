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

3. 사용자 로비 -> 활성 사용자되는 부분
4. 라이브 스트리밍 켜는 -> 꺼는 부분
+) copy_with 부분
 
 
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



<!---- 아직 완성 x 
---------------------------------------------------------

<h2>❓ 모르는 개념 정리</h2>
<details>
<summary> 🔍 자세히 알아보기! </summary>
 #### 1. 바인딩(binding) (1-1 中 ① WidgetsFlutterBinding.ensureInitialized() part)
 : 프로그램에 사용된 구성 요소의 실제 값 또는 프로퍼티를 결정짓는 행위를 의미합니다. 예를 들어 함수를 호출하는 부분에서 실제 함수가 위치한 메모리를 연결
 
 #### 2. FlutterFire CLI (1-1 中 ② Firebase.initializeApp() part)
 : 지원되는 모든 플랫폼에서 FlutterFire 설치 프로세스를 쉽게 하는 데 도움이 되는 명령을 제공하는 유용한 도구
 
 #### 3. CRUD 기능 (1-2 中 ② final DocumentReference reference part)
 : Create(생성), Read(읽기), Update(갱신), Delete(삭제)


 #### 4. Collection, Document (2-1 中 ② late Stream<QuerySnapshot> streamData part)
 ![image](https://user-images.githubusercontent.com/54922625/152805013-ab9a2658-9a9f-411f-93dc-8c95466dc451.png)
 
     1. Collection 안에 여러 개의 Document가 있고 그 안에 Document를 채우는 field가 존재한다.
     2. 즉 Collection으로 부터 특정 Document들을 가져왔기에 하나씩 까봐야 한다. 
     => 이 말은 movie라는 큰 틀에서 가져왔기 때문에 각각의 문서들을 확인해봐야 한다는 맥락이 이렇게 이해되는 것이다.
 
 #### 5. stream (2-1 中 ② late Stream<QuerySnapshot> streamData part)
     스트림은 데이터의 추가나 변경이 일어나면 이를 관찰하던데서 처리하는 방법
     => 비동기일 때 사용 (일단 이 정도 알고 넘어가고 추후 자세히 공부할 것)

 #### 6. Query (2-1 中 ② late Stream<QuerySnapshot> streamData part)
 : 데이터베이스에게 특정한 데이터를 보여달라는 클라이언트의 요청
 
 #### 7. Listener (3-1 中 ② _SearchScreenState() part)
 
 리스너는 비동기 기능을 실행할 때 활용하는 기법으로
 어떤 이벤트가 발생했을 때 실행되는 함수를 리스너라고 부른다
 
 예를 들어 사용자가 탭을 바꾸면 TabController의 addListener함수가 호출된다. 
 이를 이용해 사용자가 탭을 바꾸면 값이나 상태를 갱신할 수 있다.
 
 #### 8. <a href="https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html">BackdropFilter class</a> (detail_screen.dart 中)
 : 기존 페인팅된 콘텐츠에 필터를 적용한 다음 자식 을 페인팅하는 위젯
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

--->

