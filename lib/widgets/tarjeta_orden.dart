import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordenes/modelos/ordenmuestra.dart';
import 'package:ordenes/utils/constantes.dart';

class TarjetaOrden extends StatelessWidget {
  final OrdenMuestra order;
  final VoidCallback? click;
  const TarjetaOrden({Key? key, required this.order, this.click}) : super(key: key);

  Color _getColorByStatus() {
    switch (order.statusOrden) {
      case -1:
        return Colors.redAccent;
      case 0:
        return Colors.grey;
      case 1:
        return Colors.orangeAccent;
      case 2:
        return Colors.blueAccent;
      case 3:
        return Colors.teal;
      case 4:
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  IconData _getIconByStatus() {
    switch (order.statusOrden) {
      case -1:
        return Icons.cancel;
      case 0:
        return Icons.pending_actions;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.checklist;
      case 3:
        return Icons.delivery_dining;
      case 4:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorStatus = _getColorByStatus();
    final sombra = Constantes.colorPrimario.withOpacity(0.25);

    DateTime fecha = DateFormat('yyyy-MM-dd HH:mm:ss').parse(order.creado);

    DateTime hoy = DateTime.now();
    bool esHoy = fecha.year == hoy.year &&
                  fecha.month == hoy.month &&
                  fecha.day == hoy.day;

    return GestureDetector(
      onTap: click,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: sombra,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono del estatus
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorStatus.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconByStatus(),
                  color: colorStatus,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Información de la orden
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número de orden
                    Text(
                      "Orden #${order.idOrden}",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Cliente
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.nombreCliente.isEmpty ? "Cliente desconocido" : order.nombreCliente,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Fecha
                    Row(
                      children: [ 
                        const Icon(Icons.date_range, size: 18, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(  
                          child: Text( 
                             DateFormat(esHoy ? 'hh:mm:ss a' : 'dd/MM/yyyy hh:mm:ss a').format(fecha),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6), 

                    // Total
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 18, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          order.total.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Notas
                    if (order.notas.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note_alt, size: 18, color: Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.notas,
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 10),

                    // Estatus
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorStatus.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorStatus.withOpacity(0.3)),
                      ),
                      child: Text(
                        order.estatusTexto,
                        style: TextStyle(
                          color: colorStatus,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón detalles
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, color: Constantes.colorPrimario, size: 28),
                onPressed: click,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
