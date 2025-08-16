import 'package:flutter/material.dart';
import 'package:ordenes/utils/constantes.dart';

class ParaLlevarSwitch extends StatefulWidget {
  final bool isParaLlevarPorDefecto;
  final void Function(bool isParaLlevar)? onChanged;

  const ParaLlevarSwitch({
    Key? key,
    this.isParaLlevarPorDefecto = false, // Valor por defecto
    this.onChanged,
  }) : super(key: key);

  @override
  State<ParaLlevarSwitch> createState() => _ParaLlevarSwitchState();
}

class _ParaLlevarSwitchState extends State<ParaLlevarSwitch> {
  late bool isParaLlevar;

  @override
  void initState() {
    super.initState();
    isParaLlevar = widget.isParaLlevarPorDefecto; // Inicializa con valor por defecto
  }

  void toggle(bool paraLlevar) {
    setState(() {
      isParaLlevar = paraLlevar;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(isParaLlevar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            Icon(icon, size: 50, color: selected ? Colors.white : Colors.grey[700]),
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
