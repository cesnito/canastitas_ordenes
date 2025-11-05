import 'package:flutter/material.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/modelos/orden_tiempo_real.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/pantallas/pantalla_detalle_producto.dart';
import 'package:ordenes/pantallas/pantalla_ordenar_producto.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/utils/haptic.dart';
import 'package:ordenes/utils/mensajes.dart';
import 'package:ordenes/widgets/boton.dart';
import 'package:ordenes/widgets/boton_retardo.dart';
import 'package:ordenes/widgets/metodo_pago.dart';
import 'package:ordenes/widgets/para_llevar.dart';
import 'package:provider/provider.dart';

class PantallaDetallesOrdenCreada extends StatefulWidget {
  const PantallaDetallesOrdenCreada({super.key});

  @override
  State<PantallaDetallesOrdenCreada> createState() =>
      PantallaDetallesOrdenCreadaState();
}

class PantallaDetallesOrdenCreadaState
    extends State<PantallaDetallesOrdenCreada> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _orderNotesController = TextEditingController();

  int idOrden = 0;
  int selectedMesa = 0;
  String cliente = "";
  String anotaciones = "";

  bool paraLlevar = false;
  int metodoPago = 0;

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

  bool _loading = true;
  late OrdenTiempoReal ordenRecibida;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sólo cargar datos una vez
    if (_loading) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is OrdenTiempoReal) {
        ordenRecibida = args;
        _cargarDatosOrden();
      } else {
        // No hay args o no es el tipo esperado
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _cargarDatosOrden() async {
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);

    try {
      print(ordenRecibida);
      idOrden = ordenRecibida.idOrden;
      // Supongamos que tienes un método en la API para obtener detalles por idOrden
      await api.obtenerDetallesOrden(
        ordenRecibida.idOrden,
        onSuccess: (res) {
          final orden = res.data;
          print("Detalles de orden");
          print(orden['productos']);

          final ordendetalle = res.data;
          List<dynamic> prods = ordendetalle['productos'];
          List<Product> productosOrden = prods
              .map((item) => Product.fromJson(item))
              .toList();

          // Ahora, con los detalles cargados, actualizas el carrito y otros datos
          final cart = Provider.of<CartProvider>(context, listen: false);
          cart.setEditingMode(true);

          cart.clearCart();

          for (var p in productosOrden) {
            cart.addToCart(p); // O el método que uses para agregar productos
          }

          setState(() {
            cliente = ordendetalle['cliente'];
            anotaciones = ordendetalle['notas'];
            paraLlevar = ordendetalle['paraLlevar'];
            metodoPago = ordendetalle['metodoPago'] ?? 1; //Por defecto efectivo 
            _customerNameController.text = cliente;
            _orderNotesController.text = anotaciones;
            _loading = false;
          });
        },
        onError: (error) {
          Dialogo.mostrarMensaje(context, error.error.descripcion);
        },
      );
    } catch (e) {
      // Manejo de error
      setState(() {
        _loading = false;
      });
      Mensajes.show(context, 'Error al cargar detalles: $e');
    }
  }

  // Resto del código igual (dispose, _confirmarOrden, _realizarOrden, build...)

  @override
  void dispose() {
    _customerNameController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  void _confirmarEdicionOrden() {
    final BuildContext dialogContext = context;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar Modificación"),
        content: const Text("¿Confirmar que la orden se ha modificado?"),
        actions: [
          TextButton(
            onPressed: () {
              Haptic.sense();
              Navigator.pop(context);
              //Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text("Cancelar"),
          ),
          BotonCanastitasRetardo(
            icon: Icon(Icons.delivery_dining, color: Constantes.colorPrimario),
            label: Text(
              'Confirmar',
              style: TextStyle(color: Constantes.colorPrimario),
            ),
            color: Colors.black,
            onLongPressConfirmed: () {
              final cart = Provider.of<CartProvider>(
                dialogContext,
                listen: false,
              );
              cart.setEditingMode(true);

              if (cart.cartItems.isEmpty) {
                Mensajes.show(dialogContext, "El carrito está vacío");
                return;
              }
              Navigator.pop(dialogContext);
              Dialogo.cargando(dialogContext, "Editando orden...");
              try {
                final sesion = Provider.of<SesionProvider>(
                  dialogContext,
                  listen: false,
                ).session!;
                CanastitasAPI api = CanastitasAPI(usuario: sesion);

                final pedidoData = {
                  'idOrden': idOrden,
                  'cliente': cliente,
                  'notas': anotaciones,
                  'esParaLlevar': paraLlevar,
                  'metodoPago': metodoPago,
                  'idMesa': selectedMesa,
                  'productos': cart.cartItems,
                  'total': cart.totalPrice,
                };

                api.editarPedido(
                  pedidoData,
                  onSuccess: (response) {
                    Navigator.pop(dialogContext);
                    print('Orden editada con éxito');
                    Mensajes.show(dialogContext, "Orden editada con éxito");
                    cart.clearCart();
                    _customerNameController.clear();
                    _orderNotesController.clear();

                    Navigator.pushReplacementNamed(dialogContext, '/home');
                  },
                  onError: (error) {
                    Navigator.pop(dialogContext);
                    Mensajes.show(dialogContext, "Error al realizar la orden: ${error.error.descripcion}");
                  },
                );
              } catch (e) {
                Navigator.pop(
                  dialogContext,
                ); // cerrar diálogo en caso de error también
                Mensajes.show(dialogContext, "Error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _cancelarOrden() {
    final BuildContext dialogContext = context;
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancelar orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Por favor, ingresa el motivo de la cancelación:'),
              SizedBox(height: 10),
              TextField(
                controller: motivoController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Motivo de la cancelación',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo sin cancelar
              },
              child: Text('Volver'),
            ),
            BotonCanastitasRetardo(
              icon: Icon(
                Icons.delivery_dining,
                color: Constantes.colorPrimario,
              ),
              label: Text(
                'Confirmar cancelación',
                style: TextStyle(color: Constantes.colorPrimario),
              ),
              color: Colors.black,
              onLongPressConfirmed: () {
                final motivo = motivoController.text.trim();
                if (motivo.isEmpty) {
                  Mensajes.show(dialogContext, 'Por favor ingresa un motivo');
                  return;
                }

                final cart = Provider.of<CartProvider>(
                  dialogContext,
                  listen: false,
                );
                cart.setEditingMode(true);

                if (cart.cartItems.isEmpty) {
                  Mensajes.show(dialogContext, "No puedes cancelar con carrito vacío");
                  return;
                }
                Navigator.pop(dialogContext);
                Dialogo.cargando(dialogContext, "Cancelando orden...");
                try {
                  final sesion = Provider.of<SesionProvider>(
                    dialogContext,
                    listen: false,
                  ).session!;
                  CanastitasAPI api = CanastitasAPI(usuario: sesion);

                  final ordenData = {
                    'idOrden': idOrden,
                    'estatus': -1,
                    'motivoCancelacion': motivo,
                    'metodoPago': metodoPago    
                  };

                  api.actualizaEstatusOrden(
                    ordenData,
                    onSuccess: (response) {
                      Navigator.pop(dialogContext);
                      print('Orden cancelada con éxito');
                      Mensajes.show(dialogContext, "Orden cancelada con éxito");
                      cart.clearCart();
                      _customerNameController.clear();
                      _orderNotesController.clear();

                      Navigator.pushNamedAndRemoveUntil(
                        dialogContext,
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    },
                    onError: (error) {
                      Navigator.pop(dialogContext);
                      Mensajes.show(dialogContext, "Error al cancelar la orden: ${error.error.descripcion}");
                    },
                  );
                } catch (e) {
                  Navigator.pop(dialogContext);
                  Mensajes.show(dialogContext, "Error: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _entregarOrden() {
    final BuildContext dialogContext = context;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmar Entrega"),
        content: Text("¿Confirmas que la orden fue entregada?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          BotonCanastitasRetardo(
            icon: Icon(Icons.delivery_dining, color: Constantes.colorPrimario),
            label: Text(
              'Entregar',
              style: TextStyle(color: Constantes.colorPrimario),
            ),
            color: Colors.black,
            onLongPressConfirmed: () {
              final cart = Provider.of<CartProvider>(
                dialogContext,
                listen: false,
              );
              cart.setEditingMode(true);

              if (cart.cartItems.isEmpty) {
                Mensajes.show(dialogContext, "No puedes entregar con carrito vacío");
                return;
              }
              Navigator.pop(dialogContext);
              Dialogo.cargando(dialogContext, "Entregando orden...");
              try {
                final sesion = Provider.of<SesionProvider>(
                  dialogContext,
                  listen: false,
                ).session!;
                CanastitasAPI api = CanastitasAPI(usuario: sesion);

                final ordenData = {'idOrden': idOrden, 'estatus': 3, 'metodoPago': metodoPago}; 

                api.actualizaEstatusOrden(
                  ordenData,
                  onSuccess: (response) {
                    Navigator.pop(dialogContext);
                    print('Orden entregada con éxito');
                    Mensajes.show(dialogContext, "Orden entregada con éxito");
                    cart.clearCart();
                    _customerNameController.clear();
                    _orderNotesController.clear();

                    Navigator.pushNamedAndRemoveUntil(
                      dialogContext,
                      '/home',
                      (Route<dynamic> route) => false,
                    );
                  },
                  onError: (error) {
                    Navigator.pop(dialogContext);
                    Mensajes.show(dialogContext, "Error al entregar la orden: ${error.error.descripcion}");
                  },
                );
              } catch (e) {
                Navigator.pop(dialogContext);
                Mensajes.show(dialogContext, "Error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    cart.setEditingMode(true);

    final String titulo = "Editar orden '${cliente}' ${idOrden}";

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (cart.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: const Center(child: Text("El carrito está vacío")),
      );
    }
    return PopScope(
      canPop: false, // Evita que se cierre solo
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final salir = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("¿Salir?"),
              content: const Text("¿Seguro que quieres regresar?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Sí"),
                ),
              ],
            ),
          );
          if (salir == true) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Constantes.colorPrimario,
          title: Text(titulo),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              (ordenRecibida.ordenLista())
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "🍽️ Orden lista",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "😋", // Emoji para reflejar disfrute de la comida
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cart.cartItems[index];
                  print(product);
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
                      Mensajes.show(context, "${product.nombre} eliminado del carrito");
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
                          Text("Cantidad: ${product.cantidad}"),
                          if (product.esProductoPaquete())
                            Text(
                              "Total: ${(product.precioCliente).toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          if (!product.esProductoPaquete())
                            Text(
                              "Total: ${(product.precioCliente * product.cantidad).toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                top: 2.0,
                              ),
                              child: Text(
                                "• Opción: ${product.opcionSeleccionada!.nombre}",
                              ),
                            ),

                          if (product.notas != null &&
                              product.notas!.isNotEmpty)
                            Text("Nota: ${product.notas!}"),
                          if (product.esProductoPaquete()) Column(children: []),
                          if (product.esProductoPersonalizable())
                            Column(children: []),
                        ],
                      ),
                      trailing:
                          (ordenRecibida.ordenLista() ||
                              ordenRecibida.ordenPreparandose())
                          ? Wrap(children: [], spacing: 4)
                          : Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final updatedProduct = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PantallaDetallesProducto(
                                              product: product,
                                              isEditing: true,
                                              idOrden: idOrden,
                                            ),
                                      ),
                                    );
                                    if (updatedProduct != null) {
                                      cart.updateCartProduct(
                                        product,
                                        updatedProduct,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          "¿Eliminar producto?",
                                        ),
                                        content: Text(
                                          "¿Seguro que quieres eliminar \"${product.nombre}\" del carrito?",
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text("Cancelar"),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: const Text("Eliminar"),
                                            onPressed: () {
                                              cart.removeFromCart(product);
                                              Navigator.pop(context);
                                              Mensajes.show(context, "${product.nombre} eliminado del carrito");
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
              Text(
                "Total: \$${cart.totalPrice.toStringAsFixed(2)} MXN",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              (!ordenRecibida.ordenLista())
                  ? ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Agregar producto'),
                            onPressed: () {
                              Haptic.sense();
                              // Navigator.pushNamed(
                              //   context,
                              //   '/ordenar',
                              //   arguments: {
                              //     'esEdicion': true, // pasa el flag para saber modo
                              //   },
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PantallaOrdenarProducto(esEdicion: true),
                                ),
                              );
                            },
                          )
                  : Container(),

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
                  onChanged: (ordenRecibida.ordenLista())
                      ? null
                      : (value) {
                          setState(() {
                            selectedMesa = value!;
                          });
                        },
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                enabled: false,
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre del cliente",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => cliente = value,
              ),

              const SizedBox(height: 10),

              TextField(
                enabled: !ordenRecibida.ordenLista(),
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
                isParaLlevarPorDefecto: paraLlevar,
                onChanged: (estado) {
                  paraLlevar = estado;
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BotonCanastitasRetardo(
                    enabled: !ordenRecibida.ordenLista(),
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Constantes.colorPrimario,
                    onLongPressConfirmed: _confirmarEdicionOrden,
                  ),
                  BotonCanastitasRetardo(
                    enabled: !ordenRecibida.ordenLista(),
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onLongPressConfirmed: _cancelarOrden,
                  ),
                  // BotonCanastitas(texto: "Confirmar", onPressed: (){})
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
