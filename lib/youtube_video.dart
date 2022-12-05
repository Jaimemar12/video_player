class YoutubeVideo {
  late String _id;
  late String _url;
  late String _videoImageUrl;
  late String _title;

  String getVideoImageUrl() => _videoImageUrl;

  setVideoImageUrl(String value) {
    _videoImageUrl = value;
  }

  String getTitle() => _title;

  setTitle(String value) {
    _title = value;
  }

  String getUrl() => _url;

  setUrl(String value) {
    _url = value;
  }

  String getId() => _id;

  setId(String value) {
    _id = value;
  }
}