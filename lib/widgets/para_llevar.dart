import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';

class ParaLlevarSwitch extends StatefulWidget {
  final bool isParaLlevarPorDefecto;
  final void Function(bool isParaLlevar)? onChanged;
  final bool enabled; // ✅ Nuevo parámetro

  const ParaLlevarSwitch({
    Key? key,
    this.isParaLlevarPorDefecto = false,
    this.onChanged,
    this.enabled = true, // ✅ Por defecto está habilitado
  }) : super(key: key);

  @override
  State<ParaLlevarSwitch> createState() => _ParaLlevarSwitchState();
}

class _ParaLlevarSwitchState extends State<ParaLlevarSwitch> {
  late bool isParaLlevar;

  @override
  void initState() {
    super.initState();
    isParaLlevar = widget.isParaLlevarPorDefecto;
  }

  void toggle(bool paraLlevar) {
    if (!widget.enabled) return; // ✅ Ignora si está deshabilitado
    setState(() {
      isParaLlevar = paraLlevar;
    });
    widget.onChanged?.call(isParaLlevar);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Si está deshabilitado, aplica una opacidad baja
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            label: "Comer aquí",
            icon: Icons.restaurant,
            selected: !isParaLlevar,
            onTap: () => toggle(false),
          ),
          const SizedBox(width: 16),
          _buildButton(
            label: "Para llevar",
            icon: Icons.shopping_bag,
            selected: isParaLlevar,
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
      onTap: widget.enabled ? onTap : null, // ✅ Sin interacción si está deshabilitado
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: selected ? Constantes.colorPrimario : Colors.grey[200],
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
