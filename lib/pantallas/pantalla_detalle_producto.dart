import 'package:flutter/material.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/tipos_productos/personalizable.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/widgets/boton.dart';
import 'package:provider/provider.dart';

class PantallaDetallesProducto extends StatefulWidget {
  final Product product;
  final bool isEditing;
  final int idOrden;

  const PantallaDetallesProducto({
    Key? key,
    required this.product,
    this.isEditing = false,
    this.idOrden = 0,
  }) : super(key: key);

  @override
  State<PantallaDetallesProducto> createState() =>
      _PantallaDetallesProductoState();
}

class _PantallaDetallesProductoState extends State<PantallaDetallesProducto> {
  late int _quantity;
  late TextEditingController _noteController;
  int disponibles = 0;
  int _opcionSeleccionada = 0;
  late Product prueba;
  late ProductOption opcionSeleccionada;

  @override
  void initState() {
    super.initState();

    // Si el producto ya está en el carrito, cargamos los valores previos
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.setEditingMode(widget.isEditing);
    final existing = cartProvider.getProductFromCart(widget.product.idProducto);

    _quantity = existing?.cantidad ?? 1;
    _noteController = TextEditingController(text: existing?.notas ?? '');

    checarDisponibles();

    prueba = Product(
      idProducto: 1,
      habilitado: 1,
      nombre: "Hamburguesa",
      precioPublico: 50,
      precioPublicoDescuento: 40,
      descuento: 20,
      imagen:
          "https://img.hogar.mapfre.es/wp-content/uploads/2018/09/hamburguesa-sencilla.jpg",
      descripcion: "Hamburguesa de prueba",
      disponibles: 10,
      tipoProducto: Product.PERSONALIZABLE, // 👈 importante
      opciones: [
        ProductOption(
          idProductoOpcion: 1,
          nombre: "Sencilla",
          descripcion: "Mensaje de prueba 1",
          imagen:
              "https://img.hogar.mapfre.es/wp-content/uploads/2018/09/hamburguesa-sencilla.jpg",
          precioCliente: 22,
        ),
        ProductOption(
          idProductoOpcion: 2,
          nombre: "Doble",
          descripcion: "Mensaje de prueba 2",
          imagen:
              "https://img.hogar.mapfre.es/wp-content/uploads/2018/09/hamburguesa-sencilla.jpg",
          precioCliente: 30,
        ),
      ],
    );
  }

  void checarDisponibles() async {
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);
    final ordenData = {
      'idProducto': widget.product.idProducto,
      'idOrden': widget.idOrden,
    };
    api.verificarDisponibilidadProducto(
      ordenData,
      onSuccess: (res) {
        if (res.data != null) {
          final data = res.data;
          print(data['disponibles']);
          setState(() {
            disponibles = data['disponibles'];
          });
        } else {
          Dialogo.mostrarMensaje(
            context,
            "Error al verificar disponibilidad",
            titulo: "Error",
          );
        }
      },
      onError: (error) {
        print("Consultado con error");
        Dialogo.mostrarMensaje(
          context,
          error.error.descripcion,
          titulo: "Error",
        );
      },
    );
  }

  void _incrementQuantity() async {
    if (_quantity + 1 > disponibles) {
      Dialogo.mostrarMensaje(context, "Selecciona maximo ${disponibles}");
    } else {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addOrUpdateCart(BuildContext context) {
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);
    Dialogo.cargando(context, "Verificando disponibilidad producto...");
    final ordenData = {
      'idProducto': widget.product.idProducto,
      'idOrden': widget.idOrden,
      'cantidadSolicitado': _quantity,
    };

    BuildContext c = context;
    api.verificarDisponibilidadProducto(
      ordenData,
      onSuccess: (res) {
        if (res.data != null) {
          print("hay data");
          print(res.raw);
          final updatedProduct = widget.product.copyWith(
            cantidad: _quantity,
            notas: _noteController.text,
            opciones: widget.product.opciones
                .where((o) => o.idProductoOpcion == _opcionSeleccionada)
                .toList(),
            opcionSeleccionada: opcionSeleccionada
          );

          print(updatedProduct);

/*
          final cartProvider = Provider.of<CartProvider>(c, listen: false);
          cartProvider.addToCart(updatedProduct);

          ScaffoldMessenger.of(c).showSnackBar(
            SnackBar(
              content: Text(
                "${widget.product.nombre} agregado/actualizado en el carrito",
              ),
            ),
          );
          Navigator.pop(c);
          Navigator.pop(c);
          */
        } else {
          Dialogo.mostrarMensaje(
            c,
            "Error al verificar disponibilidad",
            titulo: "Error",
          );
        }
      },
      onError: (error) {
        print("Consultado con error");
        Dialogo.mostrarMensaje(c, error.error.descripcion, titulo: "Error");
      },
    );

    /*
    
      */
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: 'product-image-${product.idProducto}',
              child: Image.network(product.imagen, width: 250),
            ),
            const SizedBox(height: 20),
            Text(
              product.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(product.descripcion),
            const SizedBox(height: 10),
            Text(
              'Precio: MXN \$${product.precioPublico.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 30,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Text(
            //   'Antes: MXN ${product.precioPublicoDescuento}',
            //   style: const TextStyle(
            //     fontSize: 14,
            //     decoration: TextDecoration.lineThrough,
            //   ),
            // ),
            Text(
              'Disponibles: ${disponibles}',
              style: TextStyle(
                fontSize: 30,
                color: Constantes.colorPrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Selector de cantidad
            (product.esProductoSencillo())
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _decrementQuantity,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 20)),
                      IconButton(
                        onPressed: _incrementQuantity,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  )
                : Container(),

            (product.esProductoPersonalizable())
                ? ProductOptionsCardList(
                    opciones: prueba.opciones,
                    onOpcionSeleccionada: (ProductOption opcion) {
                      print(
                        "Seleccionado: ${opcion.nombre} - \$${opcion.precioCliente}",
                      );
                      // aquí puedes asignar producto.opcionSeleccionada = opcion;
                      opcionSeleccionada = opcion;
                    },
                  )
                : Container(),
            (product.esProductoPaquete())
                ? Container(child: Text("Paquete"))
                : Container(),

            const SizedBox(height: 20),

            // Campo de anotaciones
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Anotaciones (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const Spacer(),
            BotonCanastitas(
              texto: "Agregar / Actualizar en carrito",
              icono: Icons.shopping_cart,
              onPressed: () => _addOrUpdateCart(context),
            ),
          ],
        ),
      ),
    );
  }
}
