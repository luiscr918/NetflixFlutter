import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReproductorTrailerScreen extends StatelessWidget {
  final String trailerUrl;
  final String titulo;

  const ReproductorTrailerScreen({
    super.key,
    required this.trailerUrl,
    required this.titulo,
  });

  String? obtenerVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }

    return uri.queryParameters['v'];
  }

  Future<void> _abrirTrailer(BuildContext context) async {
    final uri = Uri.parse(trailerUrl);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el tráiler')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = obtenerVideoId(trailerUrl);
    final thumbnail = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(158, 32, 32, 1),
        title: Text(titulo),
      ),
      body: Center(
        child: trailerUrl.isEmpty
            ? const Text(
                "No hay tráiler disponible",
                style: TextStyle(color: Colors.white),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🖼️ PORTADA DEL TRAILER
                  if (thumbnail != null)
                    GestureDetector(
                      onTap: () => _abrirTrailer(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            thumbnail,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                          const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 80,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color.fromRGBO(158, 32, 32, 1),
                    ),
                    onPressed: () => _abrirTrailer(context),
                    icon: const Icon(Icons.movie),
                    label: const Text("Ver tráiler en YouTube"),
                  ),
                ],
              ),
      ),
    );
  }
}
