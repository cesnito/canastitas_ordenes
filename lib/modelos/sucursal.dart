class Sucursal {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String creado;
  final String actualizado;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.creado,
    required this.actualizado,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['idSucursal'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      creado: json['creado'],
      actualizado: json['actualizado'],
    );
  }
}
