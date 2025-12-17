import 'package:flutter/material.dart';
import 'package:proyecto_netflix/screens/bienvenida_screen.dart';

void main(){
  runApp(AppProyecto());
}
class AppProyecto extends StatelessWidget {
  const AppProyecto({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BienvenidaScreen(),
    );
  }
}