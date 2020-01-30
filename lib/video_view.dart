import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class VideoView extends StatefulWidget {
  var videoUrl;

  VideoView({Key key, @required this.videoUrl}) :  super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {

  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    print('video_view...');
    print(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoUrl,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        forceHideAnnotation: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      liveUIColor: Colors.amber,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
      bottomActions: <Widget>[
        PlayPauseButton(),
        RemainingDuration(),
        ProgressBar(isExpanded: true),
        CurrentPosition(),
        FullScreenButton(),
        PlaybackSpeedButton()
      ],
      onReady: () {
        print('Player is ready.');
      }
    );
  }
}
