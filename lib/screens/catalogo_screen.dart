import 'dart:convert';
import 'package:flutter/material.dart';
import 'reproduccion_screen.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  Future<Map<String, dynamic>> cargarPeliculas(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/terror.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Catálogo Terror"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cargarPeliculas(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.entries.map((categoria) {
                List peliculas = categoria.value;

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
                          final pelicula = peliculas[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReproduccionScreen(pelicula: pelicula),
                                ),
                              );
                            },
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
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
