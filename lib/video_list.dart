import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoList extends StatefulWidget {
  List<String> ids = [];
  VideoList(this.ids, {Key? key}) : super(key: key);

  @override
  VideoListState createState() => VideoListState(ids);
}

class VideoListState extends State<VideoList> {
  VideoListState(this.ids);

  List<String> ids;

  late final List<YoutubePlayerController> _controllers = ids
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
        leading: const BackButton(color: Colors.white,),
        title: const Text('Video History'),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return YoutubePlayer(
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
      ),
    );
  }
}