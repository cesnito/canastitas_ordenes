import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';

class MetodoPagoSwitch extends StatefulWidget {
  final int metodoPagoPorDefecto;
  final void Function(int metodoPagoSeleccionado)? onChanged;

  const MetodoPagoSwitch({
    Key? key,
    this.metodoPagoPorDefecto = 1, // Valor por defecto, efectivo
    this.onChanged,
  }) : super(key: key);

  @override
  State<MetodoPagoSwitch> createState() => _MetodoPagoSwitchState();
}

class _MetodoPagoSwitchState extends State<MetodoPagoSwitch> { 
  late int metodoPagoSeleccion;

  @override
  void initState() {
    super.initState();
    metodoPagoSeleccion = widget.metodoPagoPorDefecto; // Inicializa con valor por defecto
  }

  void toggle(int metodoPago) {
    setState(() {
      metodoPagoSeleccion = metodoPago;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(metodoPagoSeleccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          label: "Efectivo",
          icon: Icons.attach_money,
          selected: metodoPagoSeleccion == 1,
          onTap: () => toggle(1),
        ),
        const SizedBox(width: 16),
        _buildButton(
          label: "Tarjeta",
          icon: Icons.credit_card,
          selected: metodoPagoSeleccion == 2,
          onTap: () => toggle(2),
        ),
        const SizedBox(width: 16),
        _buildButton(
          label: "Transferencia",
          icon: Icons.swap_horiz,
          selected: metodoPagoSeleccion == 3,
          onTap: () => toggle(3),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: selected ? Constantes.colorSecundario : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Constantes.colorPrimario,
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: selected ? Constantes.colorPrimario : Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Constantes.colorPrimario : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
