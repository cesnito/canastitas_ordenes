import 'package:flutter/material.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/componentes/app_canastitas.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/pantallas/pantalla_detalle_producto.dart';
import 'package:ordenes/pantallas/pantalla_carrito_compras.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/widgets/carrito.dart';
import 'package:ordenes/widgets/tarjeta_producto.dart';
import 'package:provider/provider.dart';

class PantallaOrdenarProducto extends StatefulWidget {
  final bool esEdicion;
  PantallaOrdenarProducto({super.key, this.esEdicion = false});
  final GlobalKey _cartIconKey = GlobalKey();

  @override
  State<PantallaOrdenarProducto> createState() =>
      _PantallaOrdenarProductoState();
}

class _PantallaOrdenarProductoState extends State<PantallaOrdenarProducto> {
  OverlayEntry? overlayEntry;

  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    print("Modo editar initState: ${widget.esEdicion.toString()}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setEditingMode(widget.esEdicion);
      print("addPostFrameCallback: " + widget.esEdicion.toString());
    });

    obtenerProductos();
  }

  void obtenerProductos() async {
    setState(() {
      products = [];
      filteredProducts = [];
    });
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);
    api.obtenerProductos(
      onSuccess: (res) {
        print(res.data);
        final List<dynamic> productos = res.data;
        productos.forEach((e) => print(e['idProductoSubProducto']));
        List<Product> all = productos
            .map((item) => Product.fromJson(item))
            .toList();
        //all.forEach((e) => print(e));
        setState(() {
          products = all;
          filteredProducts = all; // Inicialmente todos
        });
      },
      onError: (error) {
        Dialogo.mostrarMensaje(context, error.error.descripcion);
      },
    );
  }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();
    print(lowerQuery);
    final resultados = products.where((p) {
      print(
        p.nombre.toLowerCase() +
            "contiene '" +
            lowerQuery +
            "': " +
            p.nombre.toLowerCase().contains(lowerQuery).toString(),
      );
      return p.nombre.toLowerCase().contains(lowerQuery);
    }).toList();
    setState(() {
      searchQuery = query;
      filteredProducts = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCanastitas(
      esEdicion: widget.esEdicion,
      onBackPresionado: () {
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //   '/home',
        //   (Route<dynamic> route) => false,
        // );
        Navigator.pop(context);
      },
      botonSuperior: (widget.esEdicion)
          ? null
          : Consumer<CartProvider>(
              builder: (context, cart, _) {
                return Carrito(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PantallaCarritoCompras(),
                      ),
                    );
                    //Navigator.pop(context);
                  },
                  itemCount: cart.itemCount,
                  cartIconKey: widget._cartIconKey,
                );
              },
            ),
      body: [
        Container(
          height: MediaQuery.of(context).size.height, // Limita altura para Expanded
          child: Column(
            children: [
              // Buscador fijo
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar producto...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterProducts,
                ),
              ),
              // Lista desplazable
              Expanded(
                child: (filteredProducts.isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return TarjetaProducto(
                            product: product,
                            click: () async {
                              final addedProduct = await Navigator.push<Product>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PantallaDetallesProducto(
                                    product: product,
                                    isEditing: widget.esEdicion,
                                    resetCantidad: true, 
                                  ),
                                ),
                              );
                              if (addedProduct != null) {
                                _runAddToCartAnimation(context, addedProduct);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _runAddToCartAnimation(BuildContext context, Product product) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Obtener la posición del icono carrito
    final renderBoxCart =
        widget._cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBoxCart == null) return;

    final cartPosition = renderBoxCart.localToGlobal(Offset.zero);
    final cartSize = renderBoxCart.size;

    // Posición inicial de la animación: centro de pantalla (puedes ajustar)
    final startPosition = Offset(
      MediaQuery.of(context).size.width / 2 - 25,
      MediaQuery.of(context).size.height / 2 - 25,
    );

    final endPosition = Offset(
      cartPosition.dx + cartSize.width / 2 - 25,
      cartPosition.dy + cartSize.height / 2 - 25,
    );

    overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedAddToCart(
          imageUrl: product.imagen,
          startOffset: startPosition,
          endOffset: endPosition,
          onAnimationComplete: () {
            overlayEntry?.remove();
          },
        );
      },
    );

    overlay.insert(overlayEntry!);
  }
}

class AnimatedAddToCart extends StatefulWidget {
  final String imageUrl;
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onAnimationComplete;

  const AnimatedAddToCart({
    super.key,
    required this.imageUrl,
    required this.startOffset,
    required this.endOffset,
    required this.onAnimationComplete,
  });

  @override
  State<AnimatedAddToCart> createState() => _AnimatedAddToCartState();
}

class _AnimatedAddToCartState extends State<AnimatedAddToCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _sizeAnimation = Tween<double>(
      begin: 50,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().whenComplete(widget.onAnimationComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: SizedBox(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            child: child,
          ),
        );
      },
      child: Image.network(widget.imageUrl),
    );
  }
}
