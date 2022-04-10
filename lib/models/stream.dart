// 사용할 플랫폼
enum StreamPlatform { youtube, twitch, other }

class StreamDestination {
  StreamPlatform platform; //플랫폼
  String url; // 해당 url

  StreamDestination({
    required this.platform,
    required this.url,
  });
}
