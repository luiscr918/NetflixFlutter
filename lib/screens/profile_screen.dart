import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? nuevaImagen;
  bool cargandoImagen = false;

  // --- CONFIGURACIÓN VISUAL ---
  final Color rojoNetflix = const Color.fromRGBO(158, 32, 32, 1);
  // Puedes usar el mismo GIF que en el catálogo o uno distinto para variar
  final String gifBackground =
      "https://i.pinimg.com/originals/0b/59/34/0b5934b623f3c6f5377f221959d77982.gif";

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> seleccionarImagen() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        nuevaImagen = img;
      });
    }
  }

  Future<void> actualizarFotoPerfil() async {
    if (nuevaImagen == null || uid == null) return;

    setState(() => cargandoImagen = true);

    try {
      final file = File(nuevaImagen!.path);

      await Supabase.instance.client.storage
          .from('fotoPerfil')
          .upload(
            '$uid.png',
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/png',
            ),
          );

      final imageUrl =
          Supabase.instance.client.storage
              .from('fotoPerfil')
              .getPublicUrl('$uid.png') +
          '?v=${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'fotoPerfil': imageUrl,
      });

      setState(() => nuevaImagen = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[900],
          content: const Text(
            'Foto actualizada correctamente',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() => cargandoImagen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: rojoNetflix,
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. GIF DE FONDO
          Positioned.fill(
            child: Image.network(
              gifBackground,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.black),
            ),
          ),

          // 2. CAPA OSCURA (Para legibilidad)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.75)),
          ),

          // 3. CONTENIDO DEL PERFIL
          uid == null
              ? const Center(
                  child: Text(
                    'Usuario no autenticado',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Column(
                        children: [
                          /// FOTO PERFIL
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: rojoNetflix,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rojoNetflix.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 67,
                                  backgroundColor: Colors.grey[900],
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 134,
                                      height: 134,
                                      child: nuevaImagen != null
                                          ? Image.file(
                                              File(nuevaImagen!.path),
                                              fit: BoxFit.cover,
                                            )
                                          : data['fotoPerfil'] != null
                                          ? Image.network(
                                              data['fotoPerfil'],
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white54,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: seleccionarImagen,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: rojoNetflix,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          if (nuevaImagen != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: rojoNetflix,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: cargandoImagen
                                    ? null
                                    : actualizarFotoPerfil,
                                icon: cargandoImagen
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text('Guardar nueva foto'),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Información del Usuario
                          _campoPerfil('Nombre', data['nombre']),
                          _campoPerfil('Correo Electrónico', data['correo']),
                          _campoPerfil(
                            'Miembro desde',
                            // Formateo simple de la fecha
                            data['fecha_registro'] != null
                                ? data['fecha_registro']
                                      .toDate()
                                      .toString()
                                      .split(' ')[0]
                                : 'No disponible',
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _campoPerfil(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                0.4,
              ), // Fondo semi-transparente para el campo
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
