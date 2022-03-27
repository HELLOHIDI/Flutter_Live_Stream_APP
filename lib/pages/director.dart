import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutterlivestreamapp/controllers/director_controller.dart';
import 'package:flutterlivestreamapp/models/director_model.dart';
import 'package:flutterlivestreamapp/models/user.dart';

class Director extends StatefulWidget {
  final String channelName;

  const Director({Key? key, required this.channelName}) : super(key: key);
  _DirectorState createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
        DirectorController directorNotifier = watch(directorController.notifier);
        DirectorModel directorData = watch(directorController);

        // directorNotifier.muteUser();
        // Text(directorData.activerUsers.elementAt(1).muted.toString());

        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text("Director"),
          ),
        );
      },
    );
  }
}
