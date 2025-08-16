import 'package:flutter/material.dart';

class Dialogo {
  static void mostrarMensaje(
    BuildContext context,
    String mensaje, {
    String titulo = "Información",
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void cargando(BuildContext context, String texto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(texto),
            ],
          ),
        );
      },
    );
  }
}
