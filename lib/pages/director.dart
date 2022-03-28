import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutterlivestreamapp/controllers/director_controller.dart';
import 'package:flutterlivestreamapp/models/director_model.dart';
import 'package:flutterlivestreamapp/models/user.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
        DirectorController directorNotifier = watch(directorController.notifier);
        DirectorModel directorData = watch(directorController);
        Size size = MediaQuery.of(context).size;
        // directorNotifier.muteUser();
        // Text(directorData.activerUsers.elementAt(1).muted.toString());

        return Scaffold(
          appBar: AppBar(),
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SafeArea(
                      child: Container(),
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
                    //RtcRemoteView.SurfaceView(uid: directorData.activeUsers.elementAt(index).uid),
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
                      //directorNotifier.toggleUserAudio(index: index, muted: true);
                    } else {
                      //directorNotifier.toggleUserAudio(index: index, muted: false);
                    }
                  },
                  icon: Icon(Icons.mic_off),
                  color: directorData.activeUsers.elementAt(index).muted ? Colors.red : Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    if (directorData.activeUsers.elementAt(index).videoDisabled) {
                      //directorNotifier.toggleUserVideo(index: index, enable: false);
                    } else {
                      //directorNotifier.toggleUserVideo(index: index, enable: true);
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
