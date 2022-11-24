// ListView(
// children: [
// player,
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.stretch,
// children: [
// _space,
// _text('Title', _videoMetaData.title),
// _space,
// _text('Channel', _videoMetaData.author),
// _space,
// Row(
// children: [
// _text(
// 'Playback Quality',
// _controller.value.playbackQuality ?? '',
// ),
// const Spacer(),
// _text(
// 'Playback Rate',
// '${_controller.value.playbackRate}x  ',
// ),
// ],
// ),
// _space,
// TextField(
// enabled: true,
// controller: _idController,
// decoration: InputDecoration(
// border: InputBorder.none,
// hintText: 'Enter youtube <link>',
// fillColor: Colors.black.withAlpha(20),
// filled: true,
// hintStyle: const TextStyle(
// fontWeight: FontWeight.w300,
// color: Colors.black,
// ),
// suffixIcon: IconButton(
// icon: const Icon(Icons.clear),
// onPressed: () => _idController.clear(),
// ),
// ),
// ),
// _space,
// Row(
// children: [
// _loadButton(),
// ],
// ),
// _space,
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// IconButton(
// icon: const Icon(Icons.skip_previous),
// onPressed: _isPlayerReady
// ? () => _controller.load(ids[
// (ids.indexOf(_controller.metadata.videoId) -
// 1) %
// ids.length])
// : null,
// ),
// IconButton(
// icon: Icon(
// _controller.value.isPlaying
// ? Icons.pause
//     : Icons.play_arrow,
// ),
// onPressed: _isPlayerReady
// ? () {
// _controller.value.isPlaying
// ? _controller.pause()
//     : _controller.play();
// setState(() {});
// }
// : null,
// ),
// IconButton(
// icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
// onPressed: _isPlayerReady
// ? () {
// _muted
// ? _controller.unMute()
//     : _controller.mute();
// setState(() {
// _muted = !_muted;
// });
// }
// : null,
// ),
// FullScreenButton(
// controller: _controller,
// color: Colors.black,
// ),
// IconButton(
// icon: const Icon(Icons.skip_next),
// onPressed: _isPlayerReady
// ? () => _controller.load(ids[
// (ids.indexOf(_controller.metadata.videoId) +
// 1) %
// ids.length])
//     : null,
// ),
// ],
// ),
// _space,
// Row(
// children: <Widget>[
// const Text(
// "Volume",
// style: TextStyle(fontWeight: FontWeight.w300),
// ),
// Expanded(
// child: Slider(
// inactiveColor: Colors.transparent,
// value: _volume,
// min: 0.0,
// max: 100.0,
// divisions: 100,
// label: '${(_volume).round()}',
// onChanged: _isPlayerReady
// ? (value) {
// setState(() {
// _volume = value;
// });
// _controller.setVolume(_volume.round());
// }
//     : null,
// ),
// ),
// ],
// ),
// _space,
// Row(
// children: [
// _downloadButton(),
// ],
// ),
// _space,
// _downloading
// ? Padding(
// padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
// child: LinearProgressIndicator(
// value: progress,
// backgroundColor: Colors.black,
// valueColor:
// const AlwaysStoppedAnimation<Color>(Colors.redAccent),
// ),
// )
// : Container()
// ],
// ),
// ),
// ],
// )