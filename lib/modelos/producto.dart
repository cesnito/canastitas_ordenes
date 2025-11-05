import 'dart:math';

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
  final double precioCliente;
  final double precioClienteDescuento;
  final int descuento;
  final String imagen;
  final String descripcion;
  final int disponibles;
  final int cantidad;
  final String notas;
  final int tipoProducto;
  final List<ProductOption> opciones;
  final ProductOption? opcion;
  final ProductOption? opcionSeleccionada;
  final List<Product> productos; // subproductos
  final String etiqueta;
  final int idProductoSubProducto;
  final double precioPaquete; // Nuevo: solo aplica si es paquete

  // NUEVO: ID único para carrito
  final String? cartId;

  const Product({
    required this.idProducto,
    required this.habilitado,
    required this.nombre,
    required this.precioCliente,
    required this.precioClienteDescuento,
    required this.descuento,
    required this.imagen,
    required this.descripcion,
    required this.disponibles,
    required this.idProductoSubProducto,
    this.cantidad = 1,
    this.notas = '',
    this.tipoProducto = 1,
    this.opciones = const [],
    this.opcion,
    this.opcionSeleccionada,
    this.productos = const [],
    this.etiqueta = 'Elige:',
    this.precioPaquete = 0.0,
    this.cartId,
  });

  Product copyWith({
    int? idProducto,
    int? habilitado,
    String? nombre,
    double? precioCliente,
    double? precioClienteDescuento,
    int? descuento,
    String? imagen,
    String? descripcion,
    int? disponibles,
    int? cantidad,
    String? notas,
    int? tipoProducto,
    List<ProductOption>? opciones,
    ProductOption? opcion,
    ProductOption? opcionSeleccionada,
    List<Product>? productos,
    String? etiqueta,
    int? idProductoSubProducto,
    double? precioPaquete,
    String? cartId,
  }) {
    return Product(
      idProducto: idProducto ?? this.idProducto,
      habilitado: habilitado ?? this.habilitado,
      nombre: nombre ?? this.nombre,
      precioCliente: precioCliente ?? this.precioCliente,
      precioClienteDescuento: precioClienteDescuento ?? this.precioClienteDescuento,
      descuento: descuento ?? this.descuento,
      imagen: imagen ?? this.imagen,
      descripcion: descripcion ?? this.descripcion,
      disponibles: disponibles ?? this.disponibles,
      cantidad: cantidad ?? this.cantidad,
      notas: notas ?? this.notas,
      tipoProducto: tipoProducto ?? this.tipoProducto,
      opciones: opciones ?? this.opciones,
      opcion: opcion ?? this.opcion,
      opcionSeleccionada: opcionSeleccionada ?? this.opcionSeleccionada,
      productos: productos ?? this.productos,
      etiqueta: etiqueta ?? this.etiqueta,
      idProductoSubProducto: idProductoSubProducto ?? this.idProductoSubProducto,
      precioPaquete: precioPaquete ?? this.precioPaquete, 
      cartId: cartId ?? this.generateCartId(),
    );
  }

  String generateCartId() {
    final random = Random().nextInt(10000000);
    return '${idProducto}_$random'; 
  }

  bool isSameProduct(Product other) => cartId == other.cartId;

  Map<String, dynamic> toJson() => {
        'idProducto': idProducto,
        'tipoProducto': tipoProducto,
        'habilitado': habilitado,
        'nombre': nombre,
        'precioCliente': precioCliente,
        'precioClienteDescuento': precioClienteDescuento,
        'descuento': descuento,
        'imagen': imagen,
        'descripcion': descripcion,
        'disponibles': disponibles,
        'cantidad': cantidad,
        'notas': notas,
        'opciones': opciones.map((o) => o.toJson()).toList(),
        'opcion': opcion?.toJson(),
        'opcionSeleccionada': opcionSeleccionada?.toJson(),
        'productos': productos.map((p) => p.toJson()).toList(),
        'etiqueta': etiqueta,
        'idProductoSubProducto': idProductoSubProducto,
        'precioPaquete': precioPaquete,
        'cartId': cartId,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    int parseIntSafe(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    final opcionesJson = json['opciones'] as List? ?? [];
    final opciones = opcionesJson.map((e) => ProductOption.fromJson(e)).toList();

    final productosJson = json['productos'] as List? ?? [];
    final productos = productosJson.map((e) => Product.fromJson(e)).toList();

    return Product(
      idProducto: parseIntSafe(json['idProducto'], 0),
      tipoProducto: parseIntSafe(json['tipoProducto'], 1),
      habilitado: parseIntSafe(json['habilitado'], 0),
      nombre: json['nombre'] ?? '',
      precioCliente: double.tryParse(json['precioCliente']?.toString() ?? '') ?? 0,
      precioClienteDescuento: double.tryParse(json['precioClienteDescuento']?.toString() ?? '') ?? 0,
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
      opcion: (json['opcion'] != null && (json['opcion'] as Map).isNotEmpty)
          ? ProductOption.fromJson(json['opcion'])
          : null,
      productos: productos,
      etiqueta: json['etiqueta'] ?? '',
      precioPaquete: double.tryParse(json['precioPaquete']?.toString() ?? '') ?? 0.0,
        cartId: json['cartId'],
      idProductoSubProducto: parseIntSafe(json['idProductoSubProducto'], 0),

    );
  }

  @override
  String toString() {
    return 'Product{idProducto: $idProducto, name: $nombre, quantity: $cantidad, precio: $precioCliente, disponibles: $disponibles, imagen: "$imagen", seleccionada: $opcionSeleccionada, subProductos: $productos, precioPaquete: $precioPaquete}';
  }

  double get precioTotal {
  double total = 0;

  if (tipoProducto == PAQUETE) {
    double totalSubproductos = 0;
    for (var sub in productos) {
      totalSubproductos += sub.opcionSeleccionada?.precioCliente ?? sub.precioCliente;
    }
    total = totalSubproductos + precioPaquete;
  } else {
    total = precioCliente;
  }

  return total * cantidad; // multiplicamos siempre por la cantidad
}
  

  bool estaHabilitado() => habilitado == 1;
  bool esProductoSencillo() => tipoProducto == SENCILLO;
  bool esProductoPersonalizable() => tipoProducto == PERSONALIZABLE;
  bool esProductoPaquete() => tipoProducto == PAQUETE;
}
