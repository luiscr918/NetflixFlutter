import 'package:flutter/material.dart';
import 'package:proyecto_netflix/screens/bienvenida_screen.dart';
import 'package:proyecto_netflix/screens/catalogo_screen.dart';
import 'package:proyecto_netflix/screens/login_screen.dart';
import 'package:proyecto_netflix/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AppProyecto());
}

class AppProyecto extends StatelessWidget {
  const AppProyecto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegisterScreen(),
        '/catalogo': (context) => CatalogoScreen(),
      },
      home: BienvenidaScreen(),
    );
  }
}
