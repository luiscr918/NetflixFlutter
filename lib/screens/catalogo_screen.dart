import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_netflix/screens/reproductor_pelicula_screen.dart';
import 'package:proyecto_netflix/screens/reproductor_trailer_screen.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  // --- CONFIGURACIÓN DE GIFS ---
  // Puedes cambiar este link por el que quieras.
  // Tip: Usa GIFs de texturas oscuras o abstractas para que no distraigan mucho.
  final String gifBackground =
      "https://i.pinimg.com/originals/0b/59/34/0b5934b623f3c6f5377f221959d77982.gif";

  Future<Map<String, dynamic>> cargarPeliculas() async {
    final ref = FirebaseDatabase.instance.ref('movies');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Catálogo",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(158, 32, 32, 1),
        actions: [
          IconButton(
            onPressed: () => cerrarSesion(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Cerrar Sesión",
            color: Colors.white,
          ),
        ],
      ),
      // Usamos Stack para poner el GIF detrás de todo
      body: Stack(
        children: [
          // 1. EL GIF DE FONDO
          Positioned.fill(
            child: Image.network(
              gifBackground,
              fit: BoxFit.cover,
              // Esto ayuda a que si el link falla, no se rompa la app
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.black),
            ),
          ),

          // 2. CAPA OSCURA (Overlay)
          // Esto es vital para que el catálogo sea legible sobre el movimiento
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.7,
              ), // Ajusta la opacidad (0.0 a 1.0)
            ),
          ),

          // 3. TU CONTENIDO ORIGINAL
          FutureBuilder<Map<String, dynamic>>(
            future: cargarPeliculas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay películas",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView(
                children: snapshot.data!.entries.map((categoria) {
                  final peliculasMap = categoria.value as Map;
                  final peliculas = peliculasMap.values.toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          categoria.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black),
                            ], // Sombra para resaltar
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: peliculas.length,
                          itemBuilder: (context, index) {
                            final pelicula =
                                peliculas[index] as Map<dynamic, dynamic>;

                            return GestureDetector(
                              onTap: () => modalPrevio(context, pelicula),
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        // Bordes redondeados para que se vea moderno
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          pelicula["imagen"],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      pelicula["titulo"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(158, 32, 32, 1),
        onPressed: () => Navigator.pushNamed(context, '/profile'),
        child: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }
}

//  Las funciones de cerrarSesion y modalPrevio

Future<void> cerrarSesion(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pop(context);
}

void modalPrevio(BuildContext context, Map pelicula) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "¿Qué deseas ver?",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Selecciona una opción para continuar con\n“${pelicula["titulo"]}”",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReproductorTrailerScreen(
                        trailerUrl: pelicula["trailerUrl"],
                        titulo: pelicula["titulo"],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text("Ver tráiler"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(158, 32, 32, 1),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReproductorPeliculaScreen(
                        peliculaUrl: pelicula["peliculaUrl"],
                        titulo: pelicula["titulo"],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.movie),
                label: const Text("Ver película"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
