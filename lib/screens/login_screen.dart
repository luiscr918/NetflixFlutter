import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://i.pinimg.com/736x/21/2f/64/212f64a50dec3d9a4a8d931efce1f1b9.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: Center(child: _contenidoLogin(context))),
      ),
    );
  }
}

Widget _contenidoLogin(BuildContext context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

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
            "Iniciar sesión",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 24),

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
            obscureText: true,
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
              onPressed: () => logearse(context, correo.text, contrasenia.text),
              child: Text("Entrar"),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/registro'),
            child: Text(
              "¿No tienes una cuenta? Registrate aquí",
              style: TextStyle(color: Color.fromRGBO(80, 208, 218, 1)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> logearse(BuildContext context, correo, contrasenia) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: contrasenia,
    );
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible:
          false, //esto hace que el usuario no pueda cerrar el alert
      builder: (context) {
        return AlertDialog(
          title: Text("Felicidades"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Inicio de sesión exitoso"),
              Text("Redirigiendo....."),
            ],
          ),
        );
      },
    );
    // 3. ESPERAR 2  segundos antes de seguir
    await Future.delayed(const Duration(seconds: 1));
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, '/catalogo');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-credential') {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Credenciales Incorrectas"),
          );
        },
      );
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}
