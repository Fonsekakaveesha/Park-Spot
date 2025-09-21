import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// ignore: use_key_in_widget_constructors
class CCTVStreamScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CCTVStreamScreenState createState() => _CCTVStreamScreenState();
}

class _CCTVStreamScreenState extends State<CCTVStreamScreen> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _videoController = VideoPlayerController.network(
      'https://your-hls-stream.m3u8', // replace with your camera stream
    );
    _chewieController = ChewieController(videoPlayerController: _videoController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live CCTV'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/events'),
          )
        ],
      ),
      body: Center(child: Chewie(controller: _chewieController)),
    );
  }
}
