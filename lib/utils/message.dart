import 'package:flutterlivestreamapp/models/user.dart';

class Message {
  String sendActiveUsers({required Set<AgoraUser> activeUsers}) {
    // ex) activeUsers uid,uid,uid,uid,
    String _userString = "activeUsers ";
    for (int i = 0; i < activeUsers.length; i++) {
      _userString = _userString + activeUsers.elementAt(i).uid.toString() + ",";
    }
    return _userString;
  }

  /// uid,uid,uid,uid,
  List<AgoraUser> parseActiveUsers({required String uids}) {
    List<String> activeUsers = uids.split(",");
    List<AgoraUser> users = [];
    for (int i = 0; i < activeUsers.length; i++) {
      if (activeUsers[i] == "") continue;
      users.add(AgoraUser(uid: int.parse(activeUsers[i])));
    }
    return users;
  }
}
