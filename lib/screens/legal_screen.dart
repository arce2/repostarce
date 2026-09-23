import 'package:flutter/material.dart';

/// Pantalla generica para mostrar un texto legal largo (politica de
/// privacidad, aviso legal...) desplazable, accesible desde dentro de la
/// app sin depender de que el usuario tenga conexion o salga a un enlace
/// externo.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            body.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}
