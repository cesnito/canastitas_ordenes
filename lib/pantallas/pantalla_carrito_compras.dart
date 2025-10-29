import 'package:flutter/material.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/modelos/usuario.dart';
import 'package:ordenes/pantallas/pantalla_detalle_producto.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/utils/haptic.dart';
import 'package:ordenes/widgets/boton.dart';
import 'package:ordenes/widgets/boton_retardo.dart';
import 'package:ordenes/widgets/para_llevar.dart';
import 'package:provider/provider.dart';

class PantallaCarritoCompras extends StatefulWidget {
  const PantallaCarritoCompras({super.key});

  @override
  State<PantallaCarritoCompras> createState() => _PantallaCarritoComprasState();
}

class _PantallaCarritoComprasState extends State<PantallaCarritoCompras> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _orderNotesController = TextEditingController();

  int selectedMesa = 0;
  String cliente = "";
  String anotaciones = "";
  bool paraLlevar = false;

  // Lista de mesas
  final List<Map<String, dynamic>> mesas = [
    {"id": 0, "nombre": "Sin Mesa"},
    {"id": 1, "nombre": "Mesa 1"},
    {"id": 2, "nombre": "Mesa 2"},
    {"id": 3, "nombre": "Mesa 3"},
    {"id": 4, "nombre": "Mesa 4"},
    {"id": 5, "nombre": "Mesa 5"},
    {"id": 6, "nombre": "Mesa 6"},
    {"id": 7, "nombre": "Mesa 7"},
    {"id": 8, "nombre": "Mesa 8"},
    {"id": 9, "nombre": "Mesa 9"},
    {"id": 10, "nombre": "Mesa 10"},
  ];

  void _confirmarOrden() {
    Haptic.sense();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar Orden"),
        content: const Text("¿Desea confirmar la orden?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancelar
            child: const Text("Cancelar"),
          ),
          BotonCanastitasRetardo(
            icon: Icon(Icons.shopping_cart_rounded),
            label: Text("Confirmar"),
            color: Constantes.colorSecundario,
            onLongPressConfirmed: () {
              Navigator.pop(context); // Cierra confirmación
              _realizarOrden(); // Va a enviar
            },
          ),
        ],
      ),
    );
  }

  void _realizarOrden() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.setEditingMode(false);

    if (cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("El carrito está vacío")));
      return;
    }
    if (cliente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingresa el nombre del cliente"),duration: Duration(seconds: 2)
        ),
      );
      return;
    }
    Dialogo.cargando(context, "Realizando orden...");
    try {
      final sesion = Provider.of<SesionProvider>(
        context,
        listen: false,
      ).session!;
      CanastitasAPI api = CanastitasAPI(usuario: sesion);

      final pedidoData = {
        'cliente': cliente,
        'notas': anotaciones,
        'idMesa': selectedMesa,
        'esParaLlevar': paraLlevar,
        'productos': cart.cartItems,
        'total': cart.totalPrice,
      };

      api.realizarPedido(
        pedidoData,
        onSuccess: (response) {
          Navigator.pop(context);
          print('Orden realizada con éxito');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Orden realizada con éxito"),duration: Duration(seconds: 2)),
          );
          cart.clearCart();
          _customerNameController.clear();
          _orderNotesController.clear();

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (Route<dynamic> route) => false,
          );
        },
        onError: (error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error al realizar la orden: ${error.error.descripcion}",
              ),duration: Duration(seconds: 2)
            ),
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // cerrar diálogo en caso de error también
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e"),duration: Duration(seconds: 2)));
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (cart.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detalles de orden")),
        body: const Center(child: Text("El carrito está vacío")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de orden"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Vaciar carrito',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("¿Vaciar carrito?"),
                  content: const Text(
                    "¿Estás seguro de que deseas eliminar todos los productos?",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Vaciar"),
                      onPressed: () {
                        cart.clearCart();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                final product = cart.cartItems[index];
                return Dismissible(
                  key: Key('${product.idProducto}-$index'),
                  background: Container(
                    color: Constantes.colorPrimario,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    cart.removeFromCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${product.nombre} eliminado del carrito",
                        ),duration: Duration(seconds: 2)
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.network(product.imagen, width: 50),
                    title: Text(
                      product.nombre,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!product.esProductoPaquete())
                          Text(
                            "Precio: MXN ${product.precioCliente.toStringAsFixed(2)}",
                          ),
                        if (product.esProductoPaquete())
                          Text(
                            "Precio: MXN ${product.precioTotal.toStringAsFixed(2)}",
                          ),
                        Text("Cantidad: ${product.cantidad}"),
                        if (product.esProductoPaquete())
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: product.productos.map((subProd) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 2.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${subProd.nombre} x${subProd.cantidad}",
                                    ),
                                    if (subProd.opcionSeleccionada != null)
                                      Text(
                                        "   ↳ ${subProd.opcionSeleccionada!.nombre}",
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        // Si es un producto PERSONALIZABLE
                        if (product.esProductoPersonalizable() &&
                            product.opcionSeleccionada != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                            child: Text(
                              "• Opción: ${product.opcionSeleccionada!.nombre}",
                            ),
                          ),
                        if (product.notas != null && product.notas!.isNotEmpty)
                          Text("Nota: ${product.notas!}"),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            print("Editando: ");
                            print(product);
                            final updatedProduct = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PantallaDetallesProducto(product: product),
                              ),
                            );
                            if (updatedProduct != null) {
                              cart.updateCartProduct(product, updatedProduct);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("¿Eliminar producto?"),
                                content: Text(
                                  "¿Seguro que quieres eliminar \"${product.nombre}\" del carrito?",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: const Text("Eliminar"),
                                    onPressed: () {
                                      Haptic.sense();
                                      cart.removeFromCart(product);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${product.nombre} eliminado del carrito",
                                          ),duration: Duration(seconds: 2)
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<int>(
                value: selectedMesa,
                decoration: const InputDecoration(
                  labelText: "Número de Mesa",
                  border: OutlineInputBorder(),
                ),
                items: mesas.map((mesa) {
                  return DropdownMenuItem<int>(
                    value: mesa["id"],
                    child: Text(mesa["nombre"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMesa = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Campos de texto para nombre y notas
            TextField(
              decoration: const InputDecoration(
                labelText: "Nombre del cliente",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => cliente = value,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _orderNotesController,
              decoration: const InputDecoration(
                labelText: "Anotaciones para la orden",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => anotaciones = value,
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            ParaLlevarSwitch(
              onChanged: (estado) {
                paraLlevar = estado;
              },
            ),

            const SizedBox(height: 20),

            Text(
              "Total: \$${cart.totalPrice.toStringAsFixed(2)} MXN",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            BotonCanastitas(
              texto: "Finalizar compra",
              onPressed: _confirmarOrden,
            ),
          ],
        ),
      ),
    );
  }
}
