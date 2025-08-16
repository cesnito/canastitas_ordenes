import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];
  final List<Product> _editCartItems = [];

  bool isEditing = false;

  CartProvider() {
    _loadCart();
    _loadEditCart();
  }

  // Getters según modo
  List<Product> get cartItems => isEditing
      ? List.unmodifiable(_editCartItems)
      : List.unmodifiable(_cartItems);

  int get itemCount => isEditing ? _editCartItems.length : _cartItems.length;

  double get totalPrice => (isEditing ? _editCartItems : _cartItems).fold(
    0.0,
    (sum, item) => sum + (item.precioPublico * item.cantidad),
  );

  // Cambiar modo edición y notificar para refrescar UI
  void setEditingMode(bool editing) {
    if (isEditing != editing) {
      isEditing = editing;
      _loadCart(); // esto internamente llamará notifyListeners()
      _loadEditCart();
    }
  }

  // Agregar producto según modo
  void addToCart(Product product) {
    final targetList = isEditing ? _editCartItems : _cartItems;
    final index = targetList.indexWhere(
      (p) => p.idProducto == product.idProducto,
    );
    if (index != -1) {
      final existing = targetList[index];
      targetList[index] = existing.copyWith(
        cantidad: product.cantidad,
        notas: product.notas.isNotEmpty ? product.notas : existing.notas,
      );
    } else {
      targetList.add(product);
    }
    _saveCart();
    notifyListeners();
  }

  // Remover producto según modo
  void removeFromCart(Product product) {
    final targetList = isEditing ? _editCartItems : _cartItems;
    targetList.removeWhere((p) => p.idProducto == product.idProducto);
    _saveCart();
    notifyListeners();
  }

  // Limpiar según modo
  void clearCart() {
    print("Carrito en modo: " + isEditing.toString());
    if (isEditing) {
      _editCartItems.clear();
    } else {
      _cartItems.clear();
    }
    _saveCart();
    notifyListeners();
  }

  // Actualizar producto según modo
  void updateCartProduct(Product oldProduct, Product newProduct) {
    final targetList = isEditing ? _editCartItems : _cartItems;
    final index = targetList.indexWhere(
      (p) => p.idProducto == oldProduct.idProducto,
    );
    if (index != -1) {
      targetList[index] = newProduct;
      _saveCart();
      notifyListeners();
    }
  }

  Product? getProductFromCart(int idProducto) {
    final targetList = isEditing ? _editCartItems : _cartItems;
    try {
      return targetList.firstWhere((p) => p.idProducto == idProducto);
    } catch (e) {
      return null;
    }
  }

  // Guardar ambos carritos
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar carrito normal
    final cartJson = _cartItems
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('cart_items', cartJson);

    // Guardar carrito edición
    final editCartJson = _editCartItems
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('cart_items_edicion', editCartJson);
  }

  // Cargar carrito normal
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList('cart_items') ?? [];

    _cartItems.clear();
    _cartItems.addAll(
      cartJson
          .map((item) => Product.fromJson(jsonDecode(item)))
          .toList(growable: true),
    );

    notifyListeners();
  }

  // Cargar carrito edición
  Future<void> _loadEditCart() async {
    final prefs = await SharedPreferences.getInstance();
    final editCartJson = prefs.getStringList('cart_items_edicion') ?? [];

    _editCartItems.clear();
    _editCartItems.addAll(
      editCartJson
          .map((item) => Product.fromJson(jsonDecode(item)))
          .toList(growable: true),
    );

    notifyListeners();
  }
}
