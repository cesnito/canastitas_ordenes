import 'package:flutter/material.dart';

class BotonCanastitasRetardo extends StatefulWidget {
  final Widget icon;
  final Widget label;
  final Color color;
  final VoidCallback onLongPressConfirmed;
  final Duration holdDuration;
  final bool enabled;

  const BotonCanastitasRetardo({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onLongPressConfirmed,
    this.holdDuration = const Duration(seconds: 1),
    this.enabled = true,
  });

  @override
  State<BotonCanastitasRetardo> createState() => _BotonCanastitasRetardoState();
}

class _BotonCanastitasRetardoState extends State<BotonCanastitasRetardo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onLongPressConfirmed();
        _controller.reset();
      }
    });
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_controller.isCompleted) {
    _controller.fling(velocity: -2.0);
  }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.enabled ? _onLongPressStart : null,
      onLongPressEnd: widget.enabled ? _onLongPressEnd : null,
      child: Stack(
        children: [
          // Barra de progreso en el fondo
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: 48,
                width:
                    MediaQuery.of(context).size.width *
                    0.25 *
                    _controller.value,
                decoration: BoxDecoration(
                  color: widget.color.withAlpha((0.8 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),

          // Botón encima
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.enabled
                    ? widget.color.withAlpha(80)
                    : widget.color.withAlpha(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: widget.icon,
              label: widget.label,
              onPressed: () {}, // bloquear toque normal
            ),
          ),
        ],
      ),
    );
  }
}
