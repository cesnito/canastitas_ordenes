import 'package:flutter/material.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/tipos_productos/personalizable.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/utils/haptic.dart';
import 'package:ordenes/widgets/boton.dart';
import 'package:provider/provider.dart';

class PantallaDetallesProducto extends StatefulWidget {
  final Product product;
  final bool isEditing;
  final bool resetCantidad;
  final int idOrden;

  const PantallaDetallesProducto({
    Key? key,
    required this.product,
    this.isEditing = false,
    this.resetCantidad = false,
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
  late Product productoDetalle;
  late ProductOption opcionSeleccionada;

  @override
  void initState() {
    super.initState();

    if (widget.resetCantidad && !widget.isEditing) {
      print("viene de pantalla ordenar");
      //viene de pantalla ordenar
      // Generar cartId para esta instancia si no existe
      productoDetalle = widget.product.copyWith(
        cartId: widget.product.generateCartId(),
        productos: widget.product.productos
            .map(
              (sub) =>
                  sub.copyWith(cartId: sub.cartId, opcionSeleccionada: null),
            )
            .toList(),
      );
      print("Nuevo ID: ${productoDetalle.cartId}");
    } else {
      print("viene de carrito de compras");
      print(widget.product);
      // Generar cartId para esta instancia si no existe
      if (widget.product.esProductoPaquete()) {
        productoDetalle = widget.product.copyWith(
          cartId: widget.product.cartId,
          productos: widget.product.productos
              .map(
                (sub) =>
                    sub.copyWith(cartId: sub.cartId, opcionSeleccionada: null),
              )
              .toList(),
        );
      } else {
        print("no es paquete, copiando opciones");
        productoDetalle = widget.product.copyWith(
          cartId: widget.product.cartId,
          opciones: widget.product.opciones,
        );
      }

      if (productoDetalle.esProductoPersonalizable()) {
        if(productoDetalle.opcionSeleccionada != null){
        opcionSeleccionada = productoDetalle.opcionSeleccionada!;
        }
      }
      print("Editar ID: ${widget.product.cartId}");
    }

    if (productoDetalle.esProductoSencillo()) {
      print("es producto sencillo");
      print(productoDetalle);
      if (productoDetalle.opcionSeleccionada == null) {
        print("ajustando porque es sencillo");
        productoDetalle = productoDetalle.copyWith(
          cartId: productoDetalle.cartId,
          opcionSeleccionada: productoDetalle.opcion,
        );
        print(
          "Producto sencillo: opción única auto seleccionada -> ${productoDetalle.opcionSeleccionada!.nombre}",
        );
      } else {
        print("ya esta seleccionado");
      }
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.setEditingMode(widget.isEditing);

    // Buscar producto existente por cartId
    final existing = cartProvider.getProductFromCartByCartId(
      productoDetalle.cartId,
    );

    _quantity = existing?.cantidad ?? 1;
    if (widget.resetCantidad && !widget.isEditing) {
      _quantity = 1;
    }

    _noteController = TextEditingController(text: existing?.notas ?? '');

    checarDisponibles();
  }

  void checarDisponibles() async {
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);
    final ordenData = {
      'idProducto': productoDetalle.idProducto,
      'idOrden': widget.idOrden,
      'producto': productoDetalle,
    };
    if (productoDetalle.esProductoSencillo()) {
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
  }

  void _incrementQuantity() async {
    setState(() {
      _quantity++;
      productoDetalle = productoDetalle.copyWith(
        cantidad: _quantity,
        cartId: productoDetalle.cartId,
      );
    });
    print("ID Actual: ${productoDetalle.cartId}");
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        productoDetalle = productoDetalle.copyWith(
          cantidad: _quantity,
          cartId: productoDetalle.cartId,
        );
      });
      print("ID Actual: ${productoDetalle.cartId}");
    }
  }

  void _addOrUpdateCart(BuildContext context) {
    Haptic.sense();
    // Validación para productos tipo paquete
    if (productoDetalle.esProductoPaquete()) {
      bool todosSeleccionados = productoDetalle.productos.every(
        (subproducto) => subproducto.opcionSeleccionada != null,
      );

      if (!todosSeleccionados) {
        Dialogo.mostrarMensaje(
          context,
          "Por favor selecciona una opción para cada subproducto del paquete.",
          titulo: "Opciones incompletas",
        );
        return; // sale del método, no agrega al carrito
      }
    } else {
      print("Es sencillo o personalizado");
      if (productoDetalle.esProductoPersonalizable()) {
        print("Es un personalizado");
        print(opcionSeleccionada);
        productoDetalle = productoDetalle.copyWith(
          cartId: productoDetalle.cartId,
          opcionSeleccionada: opcionSeleccionada,
          opciones: productoDetalle.opciones,
        );
      }
      if (productoDetalle.esProductoSencillo()) {
        productoDetalle = productoDetalle.copyWith(
          cartId: productoDetalle.cartId,
          opciones: productoDetalle.opciones,
        );
      }

      if (productoDetalle.opcionSeleccionada == null) {
        Dialogo.mostrarMensaje(
          context,
          "Por favor selecciona una opción del producto.",
          titulo: "Opciones incompletas",
        );
        return;
      }
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    late Product updatedProduct;
    if (productoDetalle.esProductoSencillo()) {
      updatedProduct = productoDetalle.copyWith(
        cantidad: _quantity,
        notas: _noteController.text,
        opciones: productoDetalle.opciones,
        opcionSeleccionada: productoDetalle.opcion,
        cartId: productoDetalle.cartId,
      );
    }
    if (productoDetalle.esProductoPersonalizable()) {
      updatedProduct = productoDetalle.copyWith(
        cantidad: _quantity,
        notas: _noteController.text,
        precioCliente: opcionSeleccionada.precioCliente,
        opciones: productoDetalle.opciones,
        opcionSeleccionada: opcionSeleccionada,
        cartId: productoDetalle.cartId,
      );
    }
    if (productoDetalle.esProductoPaquete()) {
      updatedProduct = productoDetalle.copyWith(
        cantidad: _quantity,
        notas: _noteController.text,
        productos: productoDetalle.productos,
        cartId: productoDetalle.cartId,
        precioCliente: productoDetalle.precioTotal,
      );
    }
    // Verificar si ya existe en el carrito por cartId
    print("Buscando productoDetalle: ${productoDetalle.cartId}");
    print("Buscando updatedProduct: ${updatedProduct.cartId}");
    final existingIndex = cartProvider.getCartIndexByCartId(
      updatedProduct.cartId,
    );

    print("Resultado: ${existingIndex}");
    if (existingIndex != -1) {
      print("existe, atualizando");
      cartProvider.updateCartProductAtIndex(existingIndex, updatedProduct);
    } else {
      print("no existe, creando");
      cartProvider.addToCart(updatedProduct);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${productoDetalle.nombre} agregado/actualizado en el carrito",
        ),duration: Duration(seconds: 2)
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(product.nombre)),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'product-image-${product.idProducto}',
              child: Image.network(product.imagen, width: 250),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                product.nombre,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(product.descripcion),
            const SizedBox(height: 5),
            (productoDetalle.esProductoSencillo())
                ? Center(
                    child: Text(
                      'Precio: MXN \$${product.precioCliente.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(),
            (productoDetalle.esProductoPaquete())
                ? Center(
                    child: Text(
                      'MXN \$${productoDetalle.precioTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(),
            (productoDetalle.esProductoSencillo())
                ? Center(
                    child: Text(
                      'Disponibles: ${disponibles}',
                      style: TextStyle(
                        fontSize: 30,
                        color: Constantes.colorPrimario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 20),

            (_quantity > disponibles && productoDetalle.esProductoSencillo())
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            "🚫 Estas pidiendo ${_quantity} productos cuando el máximo es ${disponibles} disponibles aprox",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("😞", style: TextStyle(fontSize: 26)),
                      ],
                    ),
                  )
                : Container(),

            // Selector de cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 35,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 30)),
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 35,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),

            (product.esProductoPersonalizable()) //Si es un producto personalizable
                ? ProductOptionsCardList(
                    opcionSeleccionada: productoDetalle.opcionSeleccionada,
                    quitarMas: true,
                    opciones: productoDetalle.opciones,
                    onOpcionSeleccionada: (ProductOption opcion) {
                      print(
                        "Seleccionado: ${opcion.nombre} - \$${opcion.precioCliente}",
                      );
                      opcionSeleccionada = opcion;
                    },
                  )
                : Container(),
            (product.esProductoPaquete())
                ? Container(child: Text("Paquete"))
                : Container(),
            (product.esProductoPaquete())
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Opciones del paquete:",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...productoDetalle.productos.asMap().entries.map((entry) {
                        final i = entry.key;
                        var subproducto = entry.value;

                        // Autoselecciona si solo hay una opción
                        if (subproducto.opciones.length == 1 &&
                            subproducto.opcionSeleccionada == null) {
                          subproducto = subproducto.copyWith(
                            opcionSeleccionada: subproducto.opciones.first,
                          );
                          productoDetalle.productos[i] =
                              subproducto; // actualiza la lista original
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Etiqueta destacada
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Text(
                                subproducto.etiqueta,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              subproducto.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ProductOptionsCardList(
                              opciones: subproducto.opciones,
                              onOpcionSeleccionada: (ProductOption opcion) {
                                setState(() {
                                  final nuevosProductos = List<Product>.from(
                                    productoDetalle.productos,
                                  );
                                  nuevosProductos[i] = subproducto.copyWith(
                                    opcionSeleccionada: opcion,
                                  );
                                  productoDetalle = productoDetalle.copyWith(
                                    cartId: productoDetalle.cartId,
                                    productos: nuevosProductos,
                                  );
                                });
                                print(
                                  "Precio total actualizado: ${productoDetalle.precioTotal}",
                                );
                              },
                              opcionSeleccionada:
                                  subproducto.opcionSeleccionada,
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }).toList(),
                    ],
                  )
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

            // Reemplaza Spacer() por SizedBox
            const SizedBox(height: 20),

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
