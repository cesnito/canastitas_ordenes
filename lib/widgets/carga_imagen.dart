import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

Widget cargarImagen(String source, {BoxFit fit = BoxFit.cover}) {
  // Detecta si es URL (comienza con http o https)
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return Image.network(
      source,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  } 
  // Detecta Base64
  else if (source.startsWith('data:image')) {
    try {
      final base64Str = source.split(',').last;
      final Uint8List bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: fit);
    } catch (e) {
      return const Icon(Icons.broken_image, size: 50);
    }
  } 
  // Otro caso: mostrar icono de error
  else {
    return const Icon(Icons.broken_image, size: 50);
  }
}
