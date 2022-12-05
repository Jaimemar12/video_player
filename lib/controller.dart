import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:video/youtube_video.dart';
import 'package:video/videos.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Controller {
  static final Controller _singleton = Controller._internal();

  factory Controller() {
    return _singleton;
  }

  Controller._internal();

  late Future<YoutubePlayerController> _futureController;
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late List<YouTubeVideo> _videoResult;
  late YoutubeMetaData _videoMetaData;
  late bool _mounted;

  final YoutubeAPI _youtubeAPI =
  YoutubeAPI('', maxResults: 10);
  final Videos _videos = Videos();

  YoutubeMetaData getVideoMetaData() => _videoMetaData;

  YoutubeAPI getYoutubeAPI() => _youtubeAPI;

  Videos getVideos() => _videos;

  Future<YoutubePlayerController> getFutureController() => _futureController;

  YoutubePlayerController getController() => _controller;

  TextEditingController getIdController() => _idController;

  TextEditingController getSeekToController() => _seekToController;

  List<YouTubeVideo> getVideoResult() => _videoResult;

  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
  }

  void listener() {
    if (_mounted &&
        !_controller.value.isFullScreen) {
      _videoMetaData = _controller.metadata;
    }
  }

  void loadVideoId(String text) async {
    _videoResult = await _youtubeAPI.search(text,
        order: 'relevance', videoDuration: 'any', type: 'video');
    String id = _videoResult[0].id.toString();
    YoutubeVideo youtubeVideo = YoutubeVideo();
    youtubeVideo.setId(id);
    _videos.removeVideo(id);
    _videos.addVideo(youtubeVideo);
    _controller.load(id);
  }

  Future<YoutubePlayerController> initializeController(bool mounted) async {
    List<YouTubeVideo> trending = await _youtubeAPI.getTrends(regionCode: "US");
    _videoMetaData = const YoutubeMetaData();
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _mounted = mounted;
    return YoutubePlayerController(
      initialVideoId: trending.elementAt(Random().nextInt(trending.length)).id.toString(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(listener);
  }

  void initialize(bool mounted) async {
    _futureController = initializeController(mounted);
    _controller = await _futureController;
  }
}
