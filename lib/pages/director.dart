import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutterlivestreamapp/controllers/director_controller.dart';
import 'package:flutterlivestreamapp/models/director_model.dart';
import 'package:flutterlivestreamapp/models/stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circular_menu/circular_menu.dart';

class Director extends StatefulWidget {
  final String channelName;
  final int uid;
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
    context.read(directorController.notifier).joinCall(channelName: widget.channelName, uid: widget.uid);
  }

  Future<dynamic> showYoutubeBottomSheet(BuildContext context, DirectorController directorNotifier) async {
    TextEditingController streamUrl = TextEditingController();
    TextEditingController streamKey = TextEditingController();
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
              TextField(
                autofocus: true,
                controller: streamUrl,
                decoration: InputDecoration(hintText: "Stream Url"),
              ),
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

  Future<dynamic> showTwitchBottomSheet(BuildContext context, Object value, DirectorController directorNotifier) {
    TextEditingController streamUrl = TextEditingController();
    TextEditingController streamKey = TextEditingController();
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
              TextField(
                autofocus: true,
                controller: streamUrl,
                decoration: InputDecoration(hintText: "Injest Url"),
              ),
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
                        directorNotifier.addPublishDestination(value as StreamPlatform, "rtmp://" + streamUrl.text.trim() + "/app/" + streamKey.text.trim());
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
              CircularMenuItem(
                icon: Icons.call_end,
                color: Colors.red,
                onTap: () {
                  directorNotifier.leaveCall();
                  Navigator.pop(context);
                },
              ),
              directorData.isLive
                  ? CircularMenuItem(
                      icon: Icons.cancel,
                      color: Colors.orange,
                      onTap: () {
                        directorNotifier.endStream();
                      },
                    )
                  : CircularMenuItem(
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
                                  list.add(
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.add),
                                        title: Text("Youtube"),
                                      ),
                                      value: StreamPlatform.youtube,
                                    ),
                                  );
                                  list.add(const PopupMenuDivider());

                                  list.add(
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.add),
                                        title: Text("Twitch"),
                                      ),
                                      value: StreamPlatform.twitch,
                                    ),
                                  );
                                  list.add(const PopupMenuDivider());

                                  list.add(
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.add),
                                        title: Text("Other"),
                                      ),
                                      value: StreamPlatform.other,
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
                                    case StreamPlatform.youtube:
                                      break;
                                  }
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                IconButton(
                  onPressed: () {
                    if (directorData.activeUsers.elementAt(index).muted) {
                      directorNotifier.toggleUserAudio(index: index, muted: true);
                    } else {
                      directorNotifier.toggleUserAudio(index: index, muted: false);
                    }
                  },
                  icon: Icon(Icons.mic_off),
                  color: directorData.activeUsers.elementAt(index).muted ? Colors.red : Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    if (directorData.activeUsers.elementAt(index).videoDisabled) {
                      directorNotifier.toggleUserVideo(index: index, enabled: false);
                    } else {
                      directorNotifier.toggleUserVideo(index: index, enabled: true);
                    }
                  },
                  icon: Icon(Icons.videocam_off),
                  color: directorData.activeUsers.elementAt(index).videoDisabled ? Colors.red : Colors.white,
                ),
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
