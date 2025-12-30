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

  final Color rojoNetflix = const Color.fromRGBO(158, 32, 32, 1);

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

      final imageUrl = Supabase.instance.client.storage
          .from('fotoPerfil')
          .getPublicUrl('$uid.png');

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({'fotoPerfil': imageUrl});

      setState(() => nuevaImagen = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada')),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text('Usuario no autenticado'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      /// FOTO PERFIL
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[800],
                            child: ClipOval(
                              child: SizedBox(
                                width: 140,
                                height: 140,
                                child: nuevaImagen != null
                                    ? Image.file(
                                        File(nuevaImagen!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : data['fotoPerfil'] != null
                                        ? Image.network(
                                            data['fotoPerfil'],
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorBuilder:
                                                (_, __, ___) =>
                                                    const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white54,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white54,
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
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (nuevaImagen != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rojoNetflix,
                          ),
                          onPressed:
                              cargandoImagen ? null : actualizarFotoPerfil,
                          icon: cargandoImagen
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Guardar foto'),
                        ),

                      const SizedBox(height: 32),

                      _campoPerfil('Nombre', data['nombre']),
                      _campoPerfil('Correo', data['correo']),
                      _campoPerfil(
                        'Fecha de registro',
                        data['fecha_registro']
                            .toDate()
                            .toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _campoPerfil(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
