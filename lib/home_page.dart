import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video/controller.dart';
import 'package:video/youtube_video.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Controller _flutterVideoController = Controller();

  double _volume = 100;
  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isPlayerReady = false;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _flutterVideoController.initialize(mounted);
  }

  @override
  void deactivate() {
    _flutterVideoController.getController().pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _flutterVideoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<YoutubePlayerController>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: snapshot.data as YoutubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.black,
              topActions: <Widget>[
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _flutterVideoController.getController().metadata.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  onPressed: () {
                    developer.log('Settings Tapped!');
                  },
                ),
              ],
              onReady: () {
                setState(() {
                  _isPlayerReady = true;
                });
              },
              onEnded: (data) {
                List<String> ids = _flutterVideoController.getVideos().getIds();
                _flutterVideoController
                    .getController()
                    .load(ids[(ids.indexOf(data.videoId) + 1) % ids.length]);
                _showSnackBar('Next Video Started!');
                setState(() {
                  _isPlaying = true;
                });
              },
            ),
            builder: (context, player) => Scaffold(
              appBar: AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Image.asset(
                    'assets/ytl.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                title: const Text(
                  'Youtube Downloader',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.video_library,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              VideoHistory(_flutterVideoController.getVideos()),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: ListView(
                children: [
                  player,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _space,
                        _text('Title',
                            _flutterVideoController.getController().metadata.title),
                        _space,
                        _text('Channel',
                            _flutterVideoController.getController().metadata.author),
                        _space,
                        Row(
                          children: [
                            _text(
                              'Playback Quality',
                              _flutterVideoController
                                      .getController()
                                      .value
                                      .playbackQuality ??
                                  '',
                            ),
                            const Spacer(),
                            _text(
                              'Playback Rate',
                              '${_flutterVideoController.getController().value.playbackRate}x  ',
                            ),
                          ],
                        ),
                        _space,
                        TextField(
                          enabled: true,
                          controller: _flutterVideoController.getIdController(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter YouTube Video Tittle or Link',
                            fillColor: Colors.black.withAlpha(20),
                            filled: true,
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _flutterVideoController
                                  .getIdController()
                                  .clear(),
                            ),
                          ),
                        ),
                        _space,
                        Row(
                          children: [
                            Expanded(
                              child: MaterialButton(
                                color: Colors.black,
                                onPressed: _isPlayerReady
                                    ? () {
                                        if (_flutterVideoController
                                            .getIdController()
                                            .text
                                            .isNotEmpty) {
                                          if (!_flutterVideoController
                                              .getIdController()
                                              .text
                                              .startsWith('https')) {
                                            _flutterVideoController.loadVideoId(
                                                _flutterVideoController
                                                    .getIdController()
                                                    .text);
                                          } else {
                                            YoutubeVideo youtubeVideo =
                                                YoutubeVideo();
                                            String id =
                                                YoutubePlayer.convertUrlToId(
                                              _flutterVideoController
                                                  .getIdController()
                                                  .text,
                                            ).toString();
                                            youtubeVideo.setId(id);
                                            _flutterVideoController
                                                .getVideos()
                                                .removeVideo(id);
                                            _flutterVideoController
                                                .getVideos()
                                                .addVideo(youtubeVideo);
                                            _flutterVideoController
                                                .getController()
                                                .load(id);
                                          }
                                          setState(() {
                                            _isPlaying = _flutterVideoController
                                                .getController()
                                                .value
                                                .isPlaying;
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        } else {
                                          _showSnackBar(
                                              'Source can\'t be empty!');
                                        }
                                      }
                                    : null,
                                disabledColor: Colors.grey,
                                disabledTextColor: Colors.black,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  child: Text(
                                    'LOAD',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _space,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: _isPlayerReady
                                  ? () {
                                      List<String> ids = _flutterVideoController
                                          .getVideos()
                                          .getIds();
                                      _flutterVideoController
                                          .getController()
                                          .load(ids[(ids.indexOf(
                                                      _flutterVideoController
                                                          .getController()
                                                          .metadata
                                                          .videoId) -
                                                  1) %
                                              ids.length]);
                                      setState(() {
                                        _isPlaying = true;
                                      });
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(_isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: _isPlayerReady
                                  ? () {
                                      _isPlaying
                                          ? _flutterVideoController
                                          .getController()
                                          .pause()
                                          : _flutterVideoController
                                          .getController()
                                          .play();
                                      setState(() {
                                        _isPlaying = !_isPlaying;
                                      });
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(_isMuted
                                  ? Icons.volume_off
                                  : Icons.volume_up),
                              onPressed: _isPlayerReady
                                  ? () {
                                      _isMuted
                                          ? _flutterVideoController
                                              .getController()
                                              .unMute()
                                          : _flutterVideoController
                                              .getController()
                                              .mute();
                                      setState(() {
                                        _isMuted = !_isMuted;
                                      });
                                    }
                                  : null,
                            ),
                            FullScreenButton(
                              controller:
                                  _flutterVideoController.getController(),
                              color: Colors.black,
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: _isPlayerReady
                                  ? () {
                                      List<String> ids = _flutterVideoController
                                          .getVideos()
                                          .getIds();
                                      _flutterVideoController
                                          .getController()
                                          .load(ids[(ids.indexOf(
                                                      _flutterVideoController
                                                          .getController()
                                                          .metadata
                                                          .videoId) +
                                                  1) %
                                              ids.length]);
                                      setState(() {
                                        _isPlaying = true;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        _space,
                        Row(
                          children: <Widget>[
                            const Text(
                              "Volume",
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            Expanded(
                              child: Slider(
                                inactiveColor: Colors.transparent,
                                value: _volume,
                                min: 0.0,
                                max: 100.0,
                                divisions: 100,
                                label: '${(_volume).round()}',
                                onChanged: _isPlayerReady
                                    ? (value) {
                                        setState(() {
                                          _volume = value;
                                        });
                                        _flutterVideoController
                                            .getController()
                                            .setVolume(_volume.round());
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        _space,
                        Row(
                          children: [
                            _downloadButton('VIDEO', 'mp4'),
                            const SizedBox(width: 10.0),
                            _downloadButton('AUDIO', 'mp3'),
                          ],
                        ),
                        _space,
                        _downloading
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1, vertical: 1),
                                    child: LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.black,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.redAccent),
                                    ),
                                  ),
                                  _space,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 30),
                                    child: Expanded(
                                      child: MaterialButton(
                                        color: Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            _downloading = false;
                                          });
                                        },
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Text(
                                            'CANCEL',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong :('));
        }
        return const Center(child: CircularProgressIndicator());
      },
      future: _flutterVideoController.getFutureController(),
    ));
  }

  Widget _text(String title, String value) {

    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  Widget _downloadButton(String tittle, String type) {
    return Expanded(
      child: MaterialButton(
        color: Colors.black,
        onPressed: _isPlayerReady
            ? () async {
                if (_flutterVideoController.getIdController().text.isNotEmpty) {
                  var permission = await Permission.storage.request();

                  if (permission.isGranted) {
                    setState(() {
                      _downloading = true;
                      _progress = 0;
                    });

                    var youtubeExplode = YoutubeExplode();
                    YoutubeVideo youtubeVideo = YoutubeVideo();
                    dynamic video;

                    if (!_flutterVideoController
                        .getIdController()
                        .text
                        .startsWith('https')) {
                      List<YouTubeVideo> videoResult =
                          await _flutterVideoController.getYoutubeAPI().search(
                              _flutterVideoController.getIdController().text,
                              order: 'relevance',
                              videoDuration: 'any',
                              type: 'video');
                      video = videoResult.first;
                      youtubeVideo.setVideoImageUrl(
                          video.thumbnail.medium.url.toString());
                      youtubeVideo.setId(video.id.toString());
                      youtubeVideo.setTitle(video.title.toString());
                    } else {
                      var url =
                          _flutterVideoController.getIdController().text.trim();
                      video = await youtubeExplode.videos.get(url);
                      youtubeVideo
                          .setVideoImageUrl(video.thumbnails.standardResUrl);
                      youtubeVideo.setId(video.id.toString());
                      youtubeVideo.setTitle(video.title.toString());
                    }
                    var manifest = await youtubeExplode.videos.streamsClient
                        .getManifest(youtubeVideo.getId());
                    var streams = manifest.muxed.withHighestBitrate();
                    var audio = streams;
                    var audioStream =
                        youtubeExplode.videos.streamsClient.get(audio);

                    String appDocPath = '/storage/emulated/0/Download';
                    var file =
                        File('$appDocPath/${youtubeVideo.getId()}.$type');

                    if (file.existsSync()) {
                      file.deleteSync();
                    }

                    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
                    var size = audio.size.totalBytes;
                    var count = 0;

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Image.network(
                              youtubeVideo.getVideoImageUrl(),
                              scale: 2,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Text(
                                'Download Has Started:\n\n${youtubeVideo.getTitle()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14.0,
                                ),
                              ),
                            )
                          ],
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    );
                    await for (final data in audioStream) {
                      count += data.length;

                      double val = (count / size);

                      var msg =
                          '${youtubeVideo.getTitle().substring(0, 20)}... Downloaded to $appDocPath/';
                      for (val; val == 1.0; val++) {
                        if (!mounted) return;
                        _showSnackBar(msg);
                      }
                      setState(() {
                        if (_downloading) {
                          _progress = val;
                        } else {
                          _progress = 0;
                          _showSnackBar("Download has been Canceled");
                          if (file.existsSync()) {
                            file.deleteSync();
                          }
                          youtubeExplode.close();
                        }
                      });
                      output.add(data);
                    }
                    youtubeExplode.close();
                    setState(() {
                      _downloading = false;
                    });
                  } else {
                    await Permission.storage.request();
                  }
                  if (!mounted) return;
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            'DOWNLOAD $tittle',
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
