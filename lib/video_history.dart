import 'package:flutter/material.dart';
import 'package:video/videos.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoHistory extends StatefulWidget {
  final Videos _videos;
  const VideoHistory(this._videos, {Key? key}) : super(key: key);

  @override
  VideoHistoryState createState() => VideoHistoryState(_videos);
}

class VideoHistoryState extends State<VideoHistory> {
  final Videos _videos;
  bool _show = true;

  VideoHistoryState(this._videos);

  late final List<YoutubePlayerController> _controllers = _videos.getIds()
      .map<YoutubePlayerController>(
        (videoId) => YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
          ),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        actions: [
          IconButton(onPressed: () {
            setState(() {
              _videos.clearList();
              _show = false;
            });
          }, icon: const Icon(Icons.delete, color: Colors.white,))
        ],
        title: const Text('Video History'),
      ),
      body: _show ? ListView.separated(
        itemBuilder: (context, index) {
          return  YoutubePlayer(
            key: ObjectKey(_controllers[index]),
            controller: _controllers[index],
            actionsPadding: const EdgeInsets.only(left: 16.0),
            bottomActions: [
              CurrentPosition(),
              const SizedBox(width: 10.0),
              ProgressBar(isExpanded: true),
              const SizedBox(width: 10.0),
              RemainingDuration(),
              FullScreenButton(),
            ],
          );
        },
        itemCount: _controllers.length,
        separatorBuilder: (context, _) => const SizedBox(height: 10.0),
      ) : null,
    );
  }
}