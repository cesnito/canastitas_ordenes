import 'package:flutter/material.dart';
import 'package:ordenes/modelos/producto.dart';

class ProductOptionsCardList extends StatefulWidget {
  final List<ProductOption> opciones;
  final Function(ProductOption) onOpcionSeleccionada; // 👈 cambia int -> ProductOption

  const ProductOptionsCardList({
    Key? key,
    required this.opciones,
    required this.onOpcionSeleccionada,
  }) : super(key: key);

  @override
  State<ProductOptionsCardList> createState() => _ProductOptionsCardListState();
}

class _ProductOptionsCardListState extends State<ProductOptionsCardList> {
  int? _opcionSeleccionada;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.opciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final opcion = widget.opciones[index];
        final seleccionada = _opcionSeleccionada == opcion.idProductoOpcion;

        return GestureDetector(
          onTap: () {
            setState(() {
              _opcionSeleccionada = opcion.idProductoOpcion;
            });
            widget.onOpcionSeleccionada(opcion); // 👈 ahora envía el objeto completo
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
                // Columna 1: Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.network(
                    opcion.imagen,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Columna 2: Nombre, descripción, precio
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          opcion.nombre,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: seleccionada ? Colors.blueAccent : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          opcion.descripcion,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$${opcion.precioCliente.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
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
