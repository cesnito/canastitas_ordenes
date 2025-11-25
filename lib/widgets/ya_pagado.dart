import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';

class PagadoSwitch extends StatefulWidget {
  final bool pagadoPorDefecto;        // true = pagado, false = no pagado
  final void Function(bool pagado)? onChanged;
  final bool enabled;

  const PagadoSwitch({
    Key? key,
    this.pagadoPorDefecto = false,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PagadoSwitch> createState() => _PagadoSwitchState();
}

class _PagadoSwitchState extends State<PagadoSwitch> {
  late bool pagado;

  @override
  void initState() {
    super.initState();
    pagado = widget.pagadoPorDefecto;
  }

  void toggle(bool value) {
    if (!widget.enabled) return;
    setState(() {
      pagado = value;
    });
    widget.onChanged?.call(pagado);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            label: "No pagado",
            icon: Icons.money_off,
            selected: !pagado,
            onTap: () => toggle(false),
          ),
          const SizedBox(width: 16),
          _buildButton(
            label: "Pagado",
            icon: Icons.attach_money,
            selected: pagado,
            onTap: () => toggle(true),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: widget.enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: selected ? Constantes.colorSecundario : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Constantes.colorSecundario,
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: selected ? Colors.white : Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
