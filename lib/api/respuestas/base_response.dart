class APIResponse{
  String raw;
  int estatus;
  final dynamic data;
  late List<APIError> errors;
  late APIError error; 

  APIResponse({this.estatus = 999, this.data, this.raw = ""}); 
}

class APIError{
  final String titulo;
  final String descripcion;

  const APIError({required this.descripcion, this.titulo = "ERROR"});

  factory APIError.fromJson(Map<String, dynamic> json) {
    return APIError(
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  @override
  String toString() => '[$titulo] $descripcion';
}