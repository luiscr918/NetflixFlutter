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

    mostrarExitoLogin(context);

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/catalogo');
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-credential' ||
        e.code == 'wrong-password' ||
        e.code == 'user-not-found') {
      mostrarErrorLogin(
        context,
        "Las credenciales no son correctas.\n¿Seguro que eres quien dices ser? ☠️",
      );
    } else if (e.code == 'invalid-email') {
      mostrarErrorLogin(
        context,
        "El formato del correo no es válido.\nAlgo no cuadra aquí… 👁️",
      );
    } else if (e.code == 'network-request-failed') {
      mostrarErrorLogin(
        context,
        "No se pudo conectar con el servidor.\n¿La señal murió primero? 📡",
      );
    } else {
      // 🔥 ERROR GENERAL
      mostrarErrorLogin(
        context,
        "Algo salió mal al intentar entrar.\nEl sistema está observando… 🩸",
      );
    }
  } catch (e) {
    // 🔥 ERROR TOTAL (no Firebase)
    mostrarErrorLogin(
      context,
      "Ocurrió un error inesperado.\nMejor no mires atrás… ☠️",
    );
  }
}

void mostrarErrorLogin(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 8),
          Text(
            "Acceso denegado",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(mensaje, style: TextStyle(color: Colors.grey.shade300)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cerrar",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

void mostrarExitoLogin(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.visibility, color: Colors.greenAccent),
          SizedBox(width: 8),
          Text(
            "Bienvenido de vuelta",
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        "Las puertas se han abierto…\nEntrando al catálogo 👁️",
        style: TextStyle(color: Colors.grey.shade300),
      ),
    ),
  );
}
