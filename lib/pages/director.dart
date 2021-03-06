import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutterlivestreamapp/controllers/director_controller.dart';
import 'package:flutterlivestreamapp/models/director_model.dart';
import 'package:flutterlivestreamapp/models/stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circular_menu/circular_menu.dart';

class Director extends StatefulWidget {
  final String channelName; // 채널명
  final int uid; //USER ID
  // 생성자
  const Director({
    Key? key,
    required this.channelName,
    required this.uid,
  }) : super(key: key);
  _DirectorState createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  @override
  void initState() {
    super.initState();
    // 알림이 통화 참여 기능을 클릭하는 우리의 디렉터 컨트롤러를 읽을 것.
    context.read(directorController.notifier).joinCall(channelName: widget.channelName, uid: widget.uid);
  }

  Future<dynamic> showYoutubeBottomSheet(BuildContext context, DirectorController directorNotifier) async {
    // RTMP를 넣어주는 과정
    // RTMP : https://ko.wikipedia.org/wiki/%EB%A6%AC%EC%96%BC_%ED%83%80%EC%9E%84_%EB%A9%94%EC%8B%9C%EC%A7%95_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C
    TextEditingController streamUrl = TextEditingController(); // 라이브 스트리밍을 위해 필요한 url
    TextEditingController streamKey = TextEditingController(); // 라이브 스트리밍을 위해 필요한 key
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Your Stream Destination",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              // 스트리밍 URL 입력창
              TextField(
                autofocus: true,
                controller: streamUrl,
                decoration: InputDecoration(hintText: "Stream Url"),
              ),
              // 스트리밍 KEY 입력창
              TextField(
                controller: streamKey,
                decoration: InputDecoration(hintText: "Stream Key"),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 버튼을 누르면 YOUTUBE 플랫폼을 등록한다.
                        directorNotifier.addPublishDestination(StreamPlatform.youtube, streamUrl.text.trim() + "/" + streamKey.text.trim());
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

  Future<dynamic> showTwitchBottomSheet(BuildContext context, DirectorController directorNotifier) {
    TextEditingController streamUrl = TextEditingController(); // 라이브 스트리밍을 위해 필요한 url
    TextEditingController streamKey = TextEditingController(); // 라이브 스트리밍을 위해 필요한 key
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Your Stream Destination",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              // 스트리밍 URL 입력창
              TextField(
                autofocus: true,
                controller: streamUrl,
                decoration: InputDecoration(hintText: "Injest Url"),
              ),
              // 스트리밍 KEY 입력창
              TextField(
                controller: streamKey,
                decoration: InputDecoration(hintText: "Stream Key"),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 버튼을 누르면 TWITCH 플랫폼을 등록한다.
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

  Widget streamButton(StreamDestination destination) {
    switch (destination.platform) {
      // youtube 버튼
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

      //  twitch 버튼
      case StreamPlatform.twitch:
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.purple),
          child: Text(
            "Twitch",
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.all(8),
          margin: const EdgeInsets.only(right: 4),
        );

      // 다른 플랫폼 버튼
      case StreamPlatform.other:
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black),
          child: Text(
            "Other",
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.all(8),
          margin: const EdgeInsets.only(right: 4),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    //  provdiver에 응답하거나 provdiver가 업데이트할 때 가능한 한 적은 수의 위젯을 재구성하는 데 사용
    return Consumer(
      // 모든 기능에 액세스하거나 데이터를 업데이트를 하게 만든다.
      builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
        DirectorController directorNotifier = watch(directorController.notifier); // director controller
        DirectorModel directorData = watch(directorController); // director model provider로 현재의 데이터를 얻을 수 잇다.
        Size size = MediaQuery.of(context).size;

        // directorNotifier.muteUser();
        // Text(directorData.activerUsers.elementAt(1).muted.toString());

        return Scaffold(
          appBar: AppBar(),
          body: CircularMenu(
            alignment: Alignment.bottomRight,
            toggleButtonColor: Colors.black87,
            toggleButtonBoxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10)
            ],
            items: [
              // 화상통화 연결을 종료하는 버튼
              CircularMenuItem(
                icon: Icons.call_end,
                color: Colors.red,
                onTap: () {
                  directorNotifier.leaveCall();
                  Navigator.pop(context);
                },
              ),
              // 만약 라이브 스트리밍 중이라면
              directorData.isLive
                  // cancel 버튼을 눌러서 스트리밍을 종료시킬 수 있다.
                  ? CircularMenuItem(
                      icon: Icons.cancel,
                      color: Colors.orange,
                      onTap: () {
                        directorNotifier.endStream();
                      },
                    )
                  // 라이브 스트리밍 중이 아니라면
                  : CircularMenuItem(
                      icon: Icons.videocam,
                      color: Colors.orange,
                      onTap: () {
                        //플랫폼이 비어있지 않다면
                        if (directorData.destinations.isNotEmpty) {
                          directorNotifier.startStream(); // 해당 플랫폼으로 스트리밍을 시작하고
                        } else {
                          // 비어있으면
                          throw ("Invalid URL"); // Invalid URL 에러를 던진다.
                        }
                      },
                    ),
            ],
            backgroundWidget: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            PopupMenuButton(
                              itemBuilder: (context) {
                                List<PopupMenuEntry<Object>> list = [];
                                // YOUTUBE 플랫폼 버튼
                                list.add(
                                  makePopMenuItem(
                                    "Youtube",
                                    StreamPlatform.youtube,
                                  ),
                                );
                                list.add(const PopupMenuDivider());

                                // TWITCH 플랫폼 버튼
                                list.add(
                                  makePopMenuItem(
                                    "Twitch",
                                    StreamPlatform.twitch,
                                  ),
                                );
                                list.add(const PopupMenuDivider());

                                // 다른 플랫폼 버튼
                                list.add(
                                  makePopMenuItem(
                                    "Other",
                                    StreamPlatform.other,
                                  ),
                                );
                                list.add(const PopupMenuDivider());
                                return list;
                              },
                              icon: Icon(Icons.add),
                              onCanceled: () {
                                print("You have canceld menu");
                              },
                              onSelected: (value) {
                                switch (value) {
                                  case StreamPlatform.youtube:
                                    showYoutubeBottomSheet(context, directorNotifier);
                                    break;
                                  case StreamPlatform.twitch:
                                    showTwitchBottomSheet(context, directorNotifier);
                                    break;
                                }
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),

                            // 라이브 스트리밍을 중지하는 함수
                            for (int i = 0; i < directorData.destinations.length; i++)
                              PopupMenuButton(
                                itemBuilder: (context) {
                                  List<PopupMenuEntry<Object>> list = [];
                                  list.add(
                                    const PopupMenuItem(child: ListTile(leading: Icon(Icons.remove), title: Text("Remove Stream")), value: 0),
                                  );
                                  return list;
                                },
                                // 각각의 플랫폼 버튼
                                child: streamButton(directorData.destinations[i]),
                                onCanceled: () {
                                  print("You have canceled the menu");
                                },
                                // 버튼을 선택하면 그 플랫폼의 스트리밍을 종료한다.
                                onSelected: (value) {
                                  directorNotifier.removePublishDestination(directorData.destinations[i].url);
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (directorData.activeUsers.isEmpty)
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: const Text("Empty Stage"),
                          ),
                        ),
                      ],
                    ),
                  ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext ctx, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: StageUser(
                              directorData: directorData,
                              directorNotifier: directorNotifier,
                              index: index,
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: directorData.activeUsers.length,
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: size.width / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Divider(
                          thickness: 3,
                          indent: 80,
                          endIndent: 80,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext ctx, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: LobbyUser(
                              directorData: directorData,
                              directorNotifier: directorNotifier,
                              index: index,
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: directorData.activeUsers.length,
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: size.width / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuEntry<Object> makePopMenuItem(String platform, StreamPlatform streamPlatform) {
    return PopupMenuItem(
      child: ListTile(
        leading: Icon(Icons.add),
        title: Text(platform),
      ),
      value: streamPlatform,
    );
  }
}

class StageUser extends StatelessWidget {
  const StageUser({
    Key? key,
    required this.directorData,
    required this.directorNotifier,
    required this.index,
  }) : super(key: key);

  final DirectorModel directorData;
  final DirectorController directorNotifier;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: directorData.activeUsers.elementAt(index).videoDisabled
                ? Stack(children: [
                    Container(
                      color: Colors.black,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Video Off",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ])
                : Stack(children: [
                    RtcRemoteView.SurfaceView(uid: directorData.activeUsers.elementAt(index).uid),
                    Align(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10)), color: directorData.activeUsers.elementAt(index).backgroundColor!.withOpacity(1)),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          directorData.activeUsers.elementAt(index).name ?? "name error",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                    ),
                  ]),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black54),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //음소거 버튼
                IconButton(
                  onPressed: () {
                    // 눌렀을 때 muted면  true
                    if (directorData.activeUsers.elementAt(index).muted) {
                      directorNotifier.toggleUserAudio(index: index, muted: true);
                    } else {
                      // unmuted면  true
                      directorNotifier.toggleUserAudio(index: index, muted: false);
                    }
                  },
                  icon: Icon(Icons.mic_off),
                  // 음소거 일때 빨강 아닐때 하양
                  color: directorData.activeUsers.elementAt(index).muted ? Colors.red : Colors.white,
                ),

                // 비디오 활성화 버튼
                IconButton(
                  onPressed: () {
                    // 눌렀을 때 videodisabled라면 enabled false
                    if (directorData.activeUsers.elementAt(index).videoDisabled) {
                      directorNotifier.toggleUserVideo(index: index, enabled: false);
                    } else {
                      // videoabled라면 enabled true
                      directorNotifier.toggleUserVideo(index: index, enabled: true);
                    }
                  },
                  icon: Icon(Icons.videocam_off),
                  // 비활성화면 빨강 아니면 하양
                  color: directorData.activeUsers.elementAt(index).videoDisabled ? Colors.red : Colors.white,
                ),

                // 활성화 유저에서 로비 유저로 강등시키는 버튼
                IconButton(
                  onPressed: () {
                    directorNotifier.demoteToLobbyUser(uid: directorData.activeUsers.elementAt(index).uid);
                  },
                  icon: Icon(Icons.arrow_downward),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LobbyUser extends StatelessWidget {
  const LobbyUser({
    Key? key,
    required this.directorData,
    required this.directorNotifier,
    required this.index,
  }) : super(key: key);

  final DirectorModel directorData;
  final DirectorController directorNotifier;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  //directorData.lobbyUsers.elementAt(index).videoDisabled ?
                  Stack(children: [
                Container(
                  color: (directorData.lobbyUsers.elementAt(index).backgroundColor != null) ? directorData.lobbyUsers.elementAt(index).backgroundColor!.withOpacity(1) : Colors.black,
                ),
                // 중앙에 사용자 이름 표시, 이름 없으면 error name 출력
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    directorData.lobbyUsers.elementAt(index).name ?? "error name",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ])
              // : RtcRemoteView.SurfaceView(
              //     uid: directorData.lobbyUsers.elementAt(index).uid,
              //   ),
              ),

          // 로비 유저에서 활성화 유저로 승격시키는 버튼
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black54),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    directorNotifier.promoteToActiveUser(uid: directorData.lobbyUsers.elementAt(index).uid);
                  },
                  icon: Icon(Icons.arrow_upward),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
