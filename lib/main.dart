import 'package:flutter/material.dart';
import 'package:proyecto_netflix/screens/bienvenida_screen.dart';
import 'package:proyecto_netflix/screens/catalogo_screen.dart';
import 'package:proyecto_netflix/screens/login_screen.dart';
import 'package:proyecto_netflix/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://iwsntkgwhgvgzgomrieo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3c250a2d3aGd2Z3pnb21yaWVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MDU2NzQsImV4cCI6MjA4MTk4MTY3NH0.gsGfChiXKvR3Irejb31lGWwC_LoGDzC2mOMg_w2h6HM',
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
