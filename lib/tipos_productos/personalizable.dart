import 'package:flutter/material.dart';
import 'package:ordenes/modelos/producto.dart';

class ProductOptionsCardList extends StatefulWidget {
  final List<ProductOption> opciones;
  final ProductOption? opcionSeleccionada; // 👈 opción actualmente seleccionada
  final Function(ProductOption) onOpcionSeleccionada;
  final bool quitarMas;

  const ProductOptionsCardList({
    Key? key,
    required this.opciones,
    required this.onOpcionSeleccionada,
    this.opcionSeleccionada,
    this.quitarMas = false
  }) : super(key: key);

  @override
  State<ProductOptionsCardList> createState() => _ProductOptionsCardListState();
}

class _ProductOptionsCardListState extends State<ProductOptionsCardList> {
  late int _opcionSeleccionadaId;

  @override
  void initState() {
    super.initState();

    // Si ya hay una opción seleccionada, úsala
    if (widget.opcionSeleccionada != null) {
      _opcionSeleccionadaId = widget.opcionSeleccionada!.idProductoOpcion;
    } else if (widget.opciones.length == 1) {
      // Si solo hay una opción, autoselecciónala
      _opcionSeleccionadaId = widget.opciones.first.idProductoOpcion;
      // Notifica inmediatamente al padre
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onOpcionSeleccionada(widget.opciones.first);
      });
    } else {
      // Ninguna seleccionada aún
      _opcionSeleccionadaId = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.opciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final opcion = widget.opciones[index];
        final seleccionada = _opcionSeleccionadaId == opcion.idProductoOpcion;

        return GestureDetector(
          onTap: () {
            setState(() {
              _opcionSeleccionadaId = opcion.idProductoOpcion;
            });
            widget.onOpcionSeleccionada(opcion);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: seleccionada ? Colors.blueAccent : Colors.grey.shade300,
                width: seleccionada ? 3 : 1.5,
              ),
              boxShadow: seleccionada
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: Image.network(
                    opcion.imagen,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          opcion.nombre,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: seleccionada
                                ? Colors.blueAccent
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          opcion.descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Precio solo si es diferente de 0
                        if (opcion.precioCliente > 0)
                          Text(
                            ((widget.quitarMas) ? "" : "+") +" \$${opcion.precioCliente.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
