import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReproduccionScreen extends StatefulWidget {
  final Map pelicula;

  const ReproduccionScreen({super.key, required this.pelicula});

  @override
  State<ReproduccionScreen> createState() => _ReproduccionScreenState();
}

class _ReproduccionScreenState extends State<ReproduccionScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.pelicula["video"]))
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.pelicula["titulo"]),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // VIDEO
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(playedColor: Colors.red),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  _controller.setVolume(1.0);
                },
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.pelicula["descripcion"],
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
