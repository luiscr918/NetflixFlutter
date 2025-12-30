import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_netflix/screens/reproductor_pelicula_screen.dart';
import 'package:proyecto_netflix/screens/reproductor_trailer_screen.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

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
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: cargarPeliculas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                          /* {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReproduccionScreen(pelicula: pelicula),
                              ),
                            );
                          }, */
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    pelicula["imagen"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  pelicula["titulo"],
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
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
      // Boton para ir a Perfil
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(158, 32, 32, 1),
        onPressed: () => Navigator.pushNamed(context, '/profile'),
        child: const Icon(
          Icons.person,
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
    );
  }
}

Future<void> cerrarSesion(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

//modal para preguntar si quiere ver la pelicula o el trailer
void modalPrevio(BuildContext context, Map pelicula) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Estás a un paso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Qué deseas hacer?"),
            const SizedBox(height: 15),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context); // cerrar modal
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
              icon: const Icon(Icons.movie_creation_outlined),
              label: const Text("Ver tráiler"),
            ),

            const SizedBox(height: 10),

            FilledButton.icon(
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
          ],
        ),
      );
    },
  );
}
