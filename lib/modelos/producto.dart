class ProductOption {
  final int idProductoOpcion;
  final String nombre;
  final String descripcion;
  final String imagen;
  final double precioCliente;

  const ProductOption({
    required this.idProductoOpcion,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.precioCliente,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      idProductoOpcion: json['idProductoOpcion'] is int
          ? json['idProductoOpcion']
          : int.tryParse(json['idProductoOpcion'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      imagen: json['imagen'] ?? '',
      precioCliente: json['precioCliente'] is num
          ? (json['precioCliente'] as num).toDouble()
          : double.tryParse(json['precioCliente'].toString()) ?? 0.0,
      descripcion: json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idProductoOpcion': idProductoOpcion,
        'nombre': nombre,
        'imagen': imagen,
        'precioCliente': precioCliente,
        'descripcion': descripcion,
      };

  @override
  String toString() {
    return 'ProductOption{idProductoOpcion: $idProductoOpcion, nombre: $nombre, descripcion: $descripcion, imagen: $imagen, precioCliente: $precioCliente}';
  }
}


class Product {
  static const SENCILLO = 1;
  static const PERSONALIZABLE = 2;
  static const PAQUETE = 3;

  final int idProducto;
  final int habilitado;
  final String nombre;
  final double precioPublico;
  final double precioPublicoDescuento;
  final int descuento;
  final String imagen;
  final String descripcion;
  final int disponibles;
  final int cantidad;
  final String notas;
  final int tipoProducto;
  final List<ProductOption> opciones;
  final ProductOption? opcionSeleccionada;

  const Product({
    required this.idProducto,
    required this.habilitado,
    required this.nombre,
    required this.precioPublico,
    required this.precioPublicoDescuento,
    required this.descuento,
    required this.imagen,
    required this.descripcion,
    required this.disponibles,
    this.cantidad = 1,
    this.notas = '',
    this.tipoProducto = 1,
    this.opciones = const [],
    this.opcionSeleccionada
  });

  Product copyWith({
    int? idProducto,
    int? habilitado,
    String? nombre,
    double? precioPublico,
    double? precioPublicoDescuento,
    int? descuento,
    String? imagen,
    String? descripcion,
    int? disponibles,
    int? cantidad,
    String? notas,
    int? tipoProducto,
    List<ProductOption>? opciones,
    ProductOption? opcionSeleccionada
  }) {
    return Product(
      idProducto: idProducto ?? this.idProducto,
      habilitado: habilitado ?? this.habilitado,
      nombre: nombre ?? this.nombre,
      precioPublico: precioPublico ?? this.precioPublico,
      precioPublicoDescuento: precioPublicoDescuento ?? this.precioPublicoDescuento,
      descuento: descuento ?? this.descuento,
      imagen: imagen ?? this.imagen,
      descripcion: descripcion ?? this.descripcion,
      disponibles: disponibles ?? this.disponibles,
      cantidad: cantidad ?? this.cantidad,
      notas: notas ?? this.notas,
      tipoProducto: tipoProducto ?? this.tipoProducto,
      opciones: opciones ?? this.opciones,
      opcionSeleccionada: opcionSeleccionada ?? this.opcionSeleccionada,
    );
  }

  Map<String, dynamic> toJson() => {
        'idProducto': idProducto,
        'tipoProducto': tipoProducto,
        'habilitado': habilitado,
        'nombre': nombre,
        'precioPublico': precioPublico,
        'precioPublicoDescuento': precioPublicoDescuento,
        'descuento': descuento,
        'imagen': imagen,
        'descripcion': descripcion,
        'disponibles': disponibles,
        'cantidad': cantidad,
        'notas': notas,
        'opciones': opciones.map((o) => o.toJson()).toList(),
        'opcionSeleccionada': opcionSeleccionada?.toJson(), 
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    int parseIntSafe(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    final opcionesJson = json['opciones'] as List? ?? [];
    final opciones = opcionesJson.map((e) => ProductOption.fromJson(e)).toList();

    return Product(
      idProducto: parseIntSafe(json['idProducto'], 0),
      tipoProducto: parseIntSafe(json['tipoProducto'], 1),
      habilitado: parseIntSafe(json['habilitado'], 0),
      nombre: json['nombre'] ?? '',
      precioPublico: double.tryParse(json['precioPublico']?.toString() ?? '') ?? 0,
      precioPublicoDescuento:
          double.tryParse(json['precioPublicoDescuento']?.toString() ?? '') ?? 0,
      descuento: parseIntSafe(json['descuento'], 0),
      imagen: json['imagen'] ?? '',
      descripcion: json['descripcion'] ?? '',
      disponibles: parseIntSafe(json['disponibles'], 0),
      cantidad: parseIntSafe(json['cantidad'], 1),
      notas: json['notas'] ?? '',
      opciones: opciones,
      opcionSeleccionada: json['opcionSeleccionada'] != null
          ? ProductOption.fromJson(json['opcionSeleccionada'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Product{idProducto: $idProducto, name: $nombre, quantity: $cantidad, disponibles: $disponibles, imagen: "$imagen", selecionada: $opcionSeleccionada}';
  }

  bool estaHabilitado() => habilitado == 1;

  bool esProductoSencillo() => tipoProducto == SENCILLO;
  bool esProductoPersonalizable() => tipoProducto == PERSONALIZABLE;
  bool esProductoPaquete() => tipoProducto == PAQUETE;
}
