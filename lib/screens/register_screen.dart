import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_netflix/const/firebase.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
        child: SafeArea(child: Center(child: _contenidoRegister(context))),
      ),
    );
  }
}

TextEditingController nombre = TextEditingController();
TextEditingController correo = TextEditingController();
TextEditingController contrasenia = TextEditingController();
Widget _contenidoRegister(BuildContext context) {
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

          SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Color.fromRGBO(158, 32, 32, 1),
                ),
              ),
              onPressed: () => registrar(
                nombre.text,
                correo.text,
                contrasenia.text,
                context,
              ),
              child: Text("Registrarse"),
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
) async {
  Future<bool> autenticacion = guardarAuth(correo, contrasenia, context);
  if (await autenticacion) {
    try {
      // 1. Obtenemos el ID único del usuario recién creado
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // 2. Creamos el mapa con la información (como el ejemplo de 'city' de la guía)
      Map<String, dynamic> datosUsuario = {
        "nombre": nombre,
        "correo": correo,
        "fecha_registro": DateTime.now(),
      };

      // 3. Guardamos en la colección usuarios usando el UID como nombre del documento
      await db.collection("usuarios").doc(uid).set(datosUsuario);

      // 4. Si todo sale bien, lo mandamos al login o inicio
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Éxito"),
            content: Text("Registrado Correctamente"),
          );
        },
      );
      await Future.delayed(Duration(seconds: 1));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // ignore: avoid_print
      print("Error al guardar en Firestore: $e");
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Error al momento de intentar Registrar"),
          );
        },
      );
    }
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
