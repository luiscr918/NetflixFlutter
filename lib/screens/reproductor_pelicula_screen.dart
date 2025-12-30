import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ReproductorPeliculaScreen extends StatefulWidget {
  final String peliculaUrl;
  final String titulo;

  const ReproductorPeliculaScreen({
    super.key,
    required this.peliculaUrl,
    required this.titulo,
  });

  @override
  State<ReproductorPeliculaScreen> createState() =>
      _ReproductorPeliculaScreenState();
}

class _ReproductorPeliculaScreenState extends State<ReproductorPeliculaScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _error = false;
  String _mensajeError = "No se pudo cargar el contenido";

  @override
  void initState() {
    super.initState();

    //  VALIDAR URL
    if (widget.peliculaUrl.isEmpty) {
      _error = true;
      _mensajeError =
          "Esta película no está disponible.\nEl archivo desapareció… 👁️";
      return;
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.peliculaUrl),
    );

    _videoController!
        .initialize()
        .then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            allowFullScreen: true,
            allowMuting: true,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black,
            ),
          );
          setState(() {});
        })
        .catchError((error) {
          // ERROR AL CARGAR VIDEO
          setState(() {
            _error = true;
            _mensajeError =
                "No se pudo reproducir la película.\nAlgo salió mal en la oscuridad… 🩸";
          });
        });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(158, 32, 32, 1),
        title: Text(widget.titulo),
      ),
      body: Center(
        child: _error
            ? _errorWidget()
            : _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(color: Colors.red),
      ),
    );
  }

  Widget _errorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.visibility_off, color: Colors.redAccent, size: 80),
        const SizedBox(height: 20),
        Text(
          _mensajeError,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 30),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Volver al catálogo"),
        ),
      ],
    );
  }
}
