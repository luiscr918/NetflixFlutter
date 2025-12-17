import 'package:flutter/material.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: contenedor(context),
    );
  }
}

Widget contenedor(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // TÍTULO
        const Text(
          "Bienvenido a Netflix",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // SUBTÍTULO
        const Text(
          "Películas y series al alcance de un clic.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        // DESCRIPCIÓN
        const Text(
          "Explora contenido, descubre nuevos favoritos y disfruta una experiencia de streaming diseñada para aprender Flutter.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 40),

        // BOTÓN LOGIN
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.account_circle),
            label: const Text("Iniciar sesión"),
          ),
        ),

        const SizedBox(height: 12),

        // BOTÓN REGISTER
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_box),
            label: const Text("Registrarse"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
