import 'dart:convert';

class Usuario {
  final String token;
  final String nombre;
  final String usuario;
  final String perfil;
  final int idSucursal;

  Usuario({
    required this.token,
    required this.nombre,
    required this.usuario,
    required this.perfil,
    required this.idSucursal,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'nombre': nombre,
        'usuario': usuario,
        'perfil': perfil,
        'idSucursal': idSucursal,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        token: json['token'],
        nombre: json['nombre'],
        usuario: json['usuario'],
        perfil: json['perfil'],
        idSucursal: json['idSucursal']
      );
}