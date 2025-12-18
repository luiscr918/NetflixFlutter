import 'package:flutter/material.dart';
import 'package:proyecto_netflix/screens/login_screen.dart';
import 'package:proyecto_netflix/screens/register_screen.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://i.pinimg.com/736x/c3/17/b6/c317b60c63bd2b554f717590c78c06b7.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: Center(child: _contenido(context))),
      ),
    );
  }
}

Widget _contenido(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(24),
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color.fromARGB(199, 1, 1, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, //
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TÍTULO
          Text(
            "Bienvenido a TerrorFlix",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          // SUBTÍTULO
          Text(
            "Solo para valientes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          SizedBox(height: 12),

          // DESCRIPCIÓN
          Text(
            "Explora un mundo de terror lleno de suspenso, misterio y horror. Una aplicación móvil dedicada únicamente a las películas que te harán temblar.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          SizedBox(height: 32),

          // BOTÓN LOGIN
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Color.fromRGBO(158, 32, 32, 1),
                ),
              ),
              onPressed: () => irLogin(context),
              icon: Icon(Icons.account_circle),
              label: Text("Iniciar sesión"),
            ),
          ),

          SizedBox(height: 12),

          // BOTÓN REGISTER
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => irRegister(context),
              icon: Icon(Icons.add_box),
              label: Text("Registrarse"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void irLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

void irRegister(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegisterScreen()),
  );
}
