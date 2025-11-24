import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordenes/api/canastitas_api.dart';
import 'package:ordenes/componentes/app_canastitas.dart';
import 'package:ordenes/modelos/ordenmuestra.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/modelos/stats_ordenes.dart';
import 'package:ordenes/pantallas/pantalla_carrito_compras.dart';
import 'package:ordenes/proveedores/carrito_proveedor.dart';
import 'package:ordenes/proveedores/sesion_provider.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/utils/dialogo.dart';
import 'package:ordenes/utils/haptic.dart';
import 'package:ordenes/widgets/carrito.dart';
import 'package:ordenes/widgets/tarjeta_orden.dart';
import 'package:provider/provider.dart';

class PantallaMostrarOrdenes extends StatefulWidget {
  final bool esEdicion;
  PantallaMostrarOrdenes({super.key, this.esEdicion = false});
  final GlobalKey _cartIconKey = GlobalKey();

  @override
  State<PantallaMostrarOrdenes> createState() => _PantallaMostrarOrdenesState();
}

class _PantallaMostrarOrdenesState extends State<PantallaMostrarOrdenes> {
  OverlayEntry? overlayEntry;

  List<OrdenMuestra> orders = [];
  List<OrdenMuestra> filteredOrders = [];
  String searchQuery = "";
  DateTime selectedDate = DateTime.now();

  late bool estaCargando;
  double totalFiltrado = 0.0;

  EstadisticasOrdenes? estadisticas;

  int metodoPagoSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    estaCargando = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setEditingMode(widget.esEdicion);
    });

    obtenerOrdenes();
  }

  void obtenerOrdenes() async {
    estaCargando = true;
    setState(() {
      orders = [];
      filteredOrders = [];
      totalFiltrado = 0.0;
    });
    final sesion = Provider.of<SesionProvider>(context, listen: false).session!;
    final api = CanastitasAPI(usuario: sesion);

    final String fechaFormato = DateFormat('yyyy-MM-dd').format(selectedDate);

    api.obtenerOrdenes2(
      fechaFormato,
      onSuccess: (res) {
        estaCargando = false;

        final data = res.data;

        // 🔥 obtener stats
        estadisticas = EstadisticasOrdenes.fromJson(data["stats"]);

        // órdenes
        final List<dynamic> ordenes = data["ordenes"];

        List<OrdenMuestra> all = ordenes
            .map((item) => OrdenMuestra.fromJson(item))
            .toList();

        setState(() {
          orders = all;
          filteredOrders = all;
          _calcularTotal();
        });
      },
      onError: (error) {
        estaCargando = false;
        Dialogo.mostrarMensaje(context, error.error.descripcion);
      },
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    Haptic.sense();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      obtenerOrdenes();
    }
  }

  // void _filterProducts(String query) {
  //   final lowerQuery = query.toLowerCase();
  //   final resultados = orders
  //       .where((p) => p.nombreCliente.toLowerCase().contains(lowerQuery))
  //       .toList();

  //   setState(() {
  //     searchQuery = query;
  //     filteredOrders = resultados;
  //     _calcularTotal();
  //   });
  // }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();

    final resultados = orders.where((p) {
      final coincideNombre = p.nombreCliente.toLowerCase().contains(lowerQuery);

      final coincideMetodo =
          (metodoPagoSeleccionado == 0) ||
          (p.metodoPago == metodoPagoSeleccionado);

      return coincideNombre && coincideMetodo;
    }).toList();

    setState(() {
      searchQuery = query;
      filteredOrders = resultados;
      _calcularTotal();
    });
  }

  void _calcularTotal() {
    totalFiltrado = filteredOrders.fold(0.0, (sum, orden) {
      // Solo sumar si la orden no está cancelada
      final estaCancelada = orden.estatusTexto?.toUpperCase() == 'CANCELADA';
      return estaCancelada ? sum : sum + (orden.total ?? 0);
    });
  }

  String obtenerHorasPrimeraYUltimaOrden() {
    if (orders.isEmpty) return "";

    // Convertir y ordenar por fecha
    final sortedOrders = List<OrdenMuestra>.from(orders)
      ..sort((a, b) {
        final fechaA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.creado);
        final fechaB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.creado);
        return fechaA.compareTo(fechaB);
      });

    // Primer y último
    final primera = sortedOrders.first;
    final ultima = sortedOrders.last;

    // Convertir a DateTime
    final fechaPrimera = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).parse(primera.creado);
    final fechaUltima = DateFormat('yyyy-MM-dd HH:mm:ss').parse(ultima.creado);

    // Mostrar solo hora:minuto
    final horaPrimera = DateFormat('hh:mm a').format(fechaPrimera);
    final horaUltima = DateFormat('hh:mm a').format(fechaUltima);

    // print('Primera orden a las: $horaPrimera');
    // print('Última orden a las: $horaUltima');
    return "${horaPrimera} / ${horaUltima}";
  }

  Widget _mpChip(int value, String label) {
    final esActivo = metodoPagoSeleccionado == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          metodoPagoSeleccionado = value;
        });
        _filterProducts(searchQuery);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: esActivo ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black54),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: esActivo ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String icono, int valor) {
    return Container(
      width: 120, // ancho sugerido
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // 🔹 centra verticalmente
        children: [
          Text(icono, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 6),
          Expanded(
            child: Center(
              child: Text(
                valor.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Constantes.colorPrimario;

    final formatter = NumberFormat.currency(
      locale: 'es_MX', // o 'es_ES' si prefieres el formato europeo
      symbol: '\$', // símbolo de moneda
      decimalDigits: 2, // siempre 2 decimales
    );

    obtenerHorasPrimeraYUltimaOrden();

    return AppCanastitas(
      selectedIndex: 2,
      esEdicion: widget.esEdicion,
      onBackPresionado: () => Navigator.pop(context),
      body: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height - 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorPrimario.withOpacity(0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // 🗓 Fecha seleccionada
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorPrimario.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimario.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "📅 (${DateFormat('EEEE', 'es_ES').format(selectedDate).capitalize()}) ${DateFormat('dd/MM/yyyy', 'es_ES').format(selectedDate)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorPrimario,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _seleccionarFecha(context),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text("Cambiar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimario,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (estadisticas != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatItem("🍔", estadisticas!.hamburguesas),
                          _buildStatItem("🌭", estadisticas!.hotdogs),
                          _buildStatItem("🍟", estadisticas!.papasfritas),
                          _buildStatItem("3×50", estadisticas!.combos3x50),
                          _buildStatItem("3×80", estadisticas!.combos3x80),
                          _buildStatItem(
                            "🍔+🍟",
                            estadisticas!.paquetehamburguesapapas,
                          ),
                        ],
                      ),

                      // Column(
                      //   children: [
                      //     _rowStat(
                      //       "🍔",
                      //       "Hamburguesas",
                      //       estadisticas!.hamburguesas,
                      //     ),
                      //     _rowStat("🌭", "Hot Dogs", estadisticas!.hotdogs),
                      //     _rowStat(
                      //       "🍟",
                      //       "Papas Fritas",
                      //       estadisticas!.papasfritas,
                      //     ),
                      //     _rowStat(
                      //       "3×50",
                      //       "Combo 3x50",
                      //       estadisticas!.combos3x50,
                      //     ),
                      //     _rowStat(
                      //       "3×80",
                      //       "Combo 3x80",
                      //       estadisticas!.combos3x80,
                      //     ),
                      //     _rowStat(
                      //       "🍔+🍟",
                      //       "Paquete H + P",
                      //       estadisticas!.paquetehamburguesapapas,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              Text(
                formatter.format(totalFiltrado),
                style: TextStyle(
                  fontSize: 22,
                  color: Constantes.colorSecundario,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                obtenerHorasPrimeraYUltimaOrden(),
                style: TextStyle(
                  fontSize: 22,
                  color: Constantes.colorSecundario,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Wrap(
                spacing: 10,
                children: [
                  _mpChip(0, "Todos"),
                  _mpChip(1, "Efectivo 💵"),
                  _mpChip(2, "Tarjeta 💳"),
                  _mpChip(3, "Transferencia 🏦"),
                  // _mpChip(4, "Otro ⋯"),
                ],
              ),
              // 🔍 Buscador
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Buscar orden...",
                    prefixIcon: Icon(Icons.search, color: colorPrimario),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorPrimario, width: 1.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorPrimario.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterProducts,
                ),
              ),

              // 📋 Lista de órdenes
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (estaCargando)
                      ? const Center(child: CircularProgressIndicator())
                      : (filteredOrders.isEmpty)
                      ? _buildEmptyState(colorPrimario)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorPrimario.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorPrimario.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  Haptic.sense();
                                  Navigator.pushNamed(
                                    context,
                                    '/detallesOrdenMuestra',
                                    arguments: order.toOrdenRT(),
                                  );
                                },
                                child: TarjetaOrden(order: order),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color colorPrimario) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorPrimario.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            "Sin datos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorPrimario.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No se encontraron órdenes para esta fecha.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
