import 'dart:ui';

class AgoraUser {
  int uid; // USER ID(이걸 통해서 모든걸 조작한다.)
  bool muted; // 음소거 여부
  bool videoDisabled; // 비디오 활성화 여부
  String? name; // 이름
  Color? backgroundColor; //배경색

  // 생성자
  AgoraUser({
    required this.uid,
    this.muted = false,
    this.videoDisabled = false,
    this.name,
    this.backgroundColor,
  });

  AgoraUser copyWith({
    int? uid,
    bool? muted,
    bool? videoDisabled,
    String? name,
    Color? backgroundColor,
  }) {
    return AgoraUser(
      uid: uid ?? this.uid,
      muted: muted ?? this.muted,
      videoDisabled: videoDisabled ?? this.videoDisabled,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
