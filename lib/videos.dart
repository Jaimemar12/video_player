import 'package:video/youtube_video.dart';

class Videos {
  static final Videos _singleton = Videos._internal();

  factory Videos() {
    return _singleton;
  }

  Videos._internal();

  final Map<String, YoutubeVideo> _playlist = <String, YoutubeVideo>{};

  addVideo(YoutubeVideo video) {
    _playlist.putIfAbsent(video.getId(), () => video);
  }

  removeVideo(String id) {
    _playlist.remove(id);
  }

  clearList() {
    _playlist.clear();
  }

  List<String> getIds() {
    List<String> ids = [];
    _playlist.forEach((key, value) {
      ids.add(value.getId());
    });
    return ids;
  }
}
