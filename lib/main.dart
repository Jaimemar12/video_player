import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ),
  );
  runApp(const YoutubePlayerApp());
}

class YoutubePlayerApp extends StatelessWidget {
  const YoutubePlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Player',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late YoutubeMetaData _videoMetaData;
  final textController = TextEditingController();
  YoutubeAPI ytApi = YoutubeAPI('');
  List<YouTubeVideo> videoResult = [];

  bool _downloading = false;
  double progress = 0;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  List<String> ids = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.black,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
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
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller.load(ids[(ids.indexOf(data.videoId) + 1) % ids.length]);
          _showSnackBar('Next Video Started!');
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
                if(_controller.value.isPlaying) deactivate();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => VideoList(ids),
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
                  _text('Title', _videoMetaData.title),
                  _space,
                  _text('Channel', _videoMetaData.author),
                  _space,
                  Row(
                    children: [
                      _text(
                        'Playback Quality',
                        _controller.value.playbackQuality ?? '',
                      ),
                      const Spacer(),
                      _text(
                        'Playback Rate',
                        '${_controller.value.playbackRate}x  ',
                      ),
                    ],
                  ),
                  _space,
                  TextField(
                    enabled: true,
                    controller: _idController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter youtube <link>',
                      fillColor: Colors.black.withAlpha(20),
                      filled: true,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _idController.clear(),
                      ),
                    ),
                  ),
                  _space,
                  Row(
                    children: [
                      _loadButton(),
                    ],
                  ),
                  _space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(ids[
                                (ids.indexOf(_controller.metadata.videoId) -
                                        1) %
                                    ids.length])
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: _isPlayerReady
                            ? () {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                                setState(() {});
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      FullScreenButton(
                        controller: _controller,
                        color: Colors.black,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(ids[
                                (ids.indexOf(_controller.metadata.videoId) +
                                        1) %
                                    ids.length])
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
                                  _controller.setVolume(_volume.round());
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  _space,
                  Row(
                    children: [
                      _downloadButton(),
                    ],
                  ),
                  _space,
                  _downloading
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                    ),
                  )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _loadButton() {
    return Expanded(
      child: MaterialButton(
        color: Colors.black,
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                    _idController.text,
                  ) ??
                      '';
                  _controller.load(id);
                  setState(() {
                    List<String> currentVideos = ids;
                    currentVideos.remove(id);
                    currentVideos.insert(0, id);
                    ids = currentVideos;
                  });
                  FocusScope.of(context).requestFocus(FocusNode());



                } else {
                  _showSnackBar('Source can\'t be empty!');
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
    );
  }

  Widget _downloadButton() {
    return Expanded(child: MaterialButton(
      color: Colors.black,
      onPressed: _isPlayerReady
          ? () async {
        if (_idController.text.isNotEmpty) {
          var permission = await Permission.storage.request();
          var url = _idController.text.trim();
          if (permission.isGranted) {
            setState(() {
              _downloading = true;
              progress = 0;
            });
            var youtubeExplode = YoutubeExplode();
            var video = await youtubeExplode.videos.get(url);
            var id = video.id;
            var manifest = await youtubeExplode.videos.streamsClient
                .getManifest(id);
            var streams = manifest.muxed.withHighestBitrate();
            var audio = streams;
            var audioStream =
            youtubeExplode.videos.streamsClient.get(audio);

            String appDocPath = '/storage/emulated/0/Download';
            var file = File('$appDocPath/${video.id}.mp4');

            if (file.existsSync()) {
              file.deleteSync();
            }

            var output =
            file.openWrite(mode: FileMode.writeOnlyAppend);
            var size = audio.size.totalBytes;
            var count = 0;

            await for (final data in audioStream) {
              count += data.length;

              double val = (count / size);

              var msg =
                  '${video.title.substring(0, 20)}... Downloaded to $appDocPath/';
              for (val; val == 1.0; val++) {
                if(!mounted) return;
                _showSnackBar(msg);
              }
              setState(() {
                progress = val;
              });
              output.add(data);
            }
          } else {
            await Permission.storage.request();
          }
          if(!mounted) return;
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _downloading = false;
          });
        } else {
          _showSnackBar('Source can\'t be empty!');
        }
      }
          : null,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          'DOWNLOAD',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),);
  }

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
}
