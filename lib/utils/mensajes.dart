import 'package:flutter/material.dart';

class Mensajes { 
  static void show(
    BuildContext context,
    String message, { 
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}