import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

import 'pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // A widget which will be started on application startup
        home: const Home(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required String this.title}) : super(key: key);

  final String title;

  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "dda7781fb47849bab9ad4bbfb9a3c59b",
      channelName: "test",
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone
    ],
  );
  @override
  void initState() {
    super.initState();
    client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          AgoraVideoViewer(client: client),
          AgoraVideoButtons(client: client),
        ],
      ),
    );
  }
}
