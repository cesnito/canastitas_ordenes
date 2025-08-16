import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';

class BotonCanastitas extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final double? altura;
  final IconData? icono;

  const BotonCanastitas({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.altura,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icono, color: Constantes.colorSecundario,),  
      onPressed: onPressed,
      label: Text(texto, style: TextStyle(color: Constantes.colorSecundario),),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(altura ?? 45),
        backgroundColor: Constantes.colorPrimario
      ),
    );
  }
}