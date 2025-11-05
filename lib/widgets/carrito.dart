// carrito.dart
import 'package:flutter/material.dart';

class Carrito extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;
  final GlobalKey? cartIconKey;

  const Carrito({
    Key? key,
    required this.itemCount,
    required this.onPressed,
    this.cartIconKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          key: cartIconKey,
          icon: const Icon(Icons.shopping_cart),
          iconSize: 35,
          onPressed: onPressed,
        ),
        if (itemCount > 0)
          Positioned(
            right: 5,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
