import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_netflix/const/firebase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  XFile? imagen;
  void cambiarImagen(imagenNueva) {
    setState(() {
      imagen = imagenNueva;
    });
  }

  bool cargando = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://i.pinimg.com/736x/1a/10/72/1a10720b00b3c1f780de2dd3663d6722.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _contenidoRegister(
              context,
              cambiarImagen,
              imagen,
              cargando,
              () {
                setState(() {
                  cargando = true;
                });
              },
              () {
                setState(() {
                  cargando = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

TextEditingController nombre = TextEditingController();
TextEditingController correo = TextEditingController();
TextEditingController contrasenia = TextEditingController();
Widget _contenidoRegister(
  BuildContext context,
  cambiarImagen,
  imagen,
  bool cargando,
  VoidCallback iniciarCarga,
  VoidCallback detenerCarga,
) {
  return Padding(
    padding: EdgeInsets.all(24),
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color.fromARGB(199, 1, 1, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Registro",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 24),

          TextField(
            controller: nombre,
            decoration: InputDecoration(
              labelText: "Nombre",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 16),

          TextField(
            controller: correo,
            decoration: InputDecoration(
              labelText: "Correo",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.email, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 16),

          TextField(
            controller: contrasenia,
            decoration: InputDecoration(
              labelText: "Contraseña",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          Text(""),
          FilledButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Color.fromRGBO(139, 55, 55, 1),
              ),
            ),
            onPressed: () => abrirGaleria(cambiarImagen),
            label: Text("Seleccionar foto de perfil"),
            icon: Icon(Icons.image_search),
          ),
          SizedBox(height: 16),

          CircleAvatar(
            radius: 60, //  tamaño (60 = 120x120)
            backgroundColor: Colors.grey[800],
            backgroundImage: imagen != null
                ? FileImage(File(imagen!.path))
                : null,
            child: imagen == null
                ? const Icon(Icons.person, size: 60, color: Colors.white54)
                : null,
          ),

          SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey; // color cuando está deshabilitado
                  }
                  return const Color.fromRGBO(158, 32, 32, 1); // color normal
                }),
              ),
              onPressed: cargando
                  ? null
                  : () async {
                      iniciarCarga();
                      await registrar(
                        nombre.text,
                        correo.text,
                        contrasenia.text,
                        context,
                        imagen,
                      );
                      detenerCarga();
                    },
              child: cargando
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Registrarse"),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              "¿Ya tienes una cuenta? Inicia sesión aquí",
              style: TextStyle(color: Color.fromRGBO(80, 208, 218, 1)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> registrar(
  String nombre,
  String correo,
  String contrasenia,
  BuildContext context,
  XFile? imagen,
) async {
  bool autenticado = await guardarAuth(correo, contrasenia, context);
  if (!autenticado) return;

  try {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> datosUsuario = {
      "nombre": nombre,
      "correo": correo,
      "fecha_registro": DateTime.now(),
    };

    if (imagen != null) {
      bool imagenBien = await guardarImagenStorage(uid, imagen);
      if (!imagenBien) {
        mostrarError(context, "Error al subir la imagen");
        return;
      }

      final imageUrl = Supabase.instance.client.storage
          .from('fotoPerfil')
          .getPublicUrl('$uid.png');

      datosUsuario['fotoPerfil'] = imageUrl;
    }

    await db.collection("usuarios").doc(uid).set(datosUsuario);

    mostrarExito(context);
  } catch (e) {
    mostrarError(context, "Error al registrar usuario");
  }
}

Future<bool> guardarAuth(String correo, String contrasenia, context) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: correo,
      password: contrasenia,
    );
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Contraseña no válida"),
          );
        },
      );
    } else if (e.code == 'email-already-in-use') {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Email ya en uso"),
          );
        },
      );
    } else if (e.code == 'invalid-email') {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Formato de Correo inválido"),
          );
        },
      );
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
  return false;
}

//funcion para cargar una foto de perfil
Future<void> abrirGaleria(cambiarImagen) async {
  final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
  cambiarImagen(imagen);
}

Future<bool> guardarImagenStorage(String uid, XFile imagen) async {
  try {
    final supabase = Supabase.instance.client;

    final file = File(imagen.path);

    await supabase.storage
        .from('fotoPerfil')
        .upload(
          '$uid.png',
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/png',
          ),
        );

    return true;
  } catch (e) {
    print('Error subiendo imagen: $e');
    return false;
  }
}

void mostrarExito(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Éxito"),
      content: const Text("Registrado correctamente"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text("Aceptar"),
        ),
      ],
    ),
  );
}

void mostrarError(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Error"),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Aceptar"),
        ),
      ],
    ),
  );
}
