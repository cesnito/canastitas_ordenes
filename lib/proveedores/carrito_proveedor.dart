import 'dart:convert';
import 'dart:math';
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

  // double get totalPrice => (isEditing ? _editCartItems : _cartItems).fold(
  //   0.0,
  //   (sum, item) => sum + (item.precioCliente * item.cantidad),
  // );

  double get totalPrice {
    final list = isEditing ? _editCartItems : _cartItems;
    return list.fold(0.0, (sum, item) {
      double precio = 0.0;

      if (item.esProductoSencillo() || item.esProductoPersonalizable()) {
        precio = item.precioCliente;
      } else if (item.esProductoPaquete()) {
        // Suma los precios de las opciones seleccionadas de los subproductos
        double subproductosPrecio = item.productos.fold(0.0, (subSum, sub) {
          print("Sumando: ${(sub.opcionSeleccionada?.precioCliente ?? 0.0)}");
          return subSum + (sub.opcionSeleccionada?.precioCliente ?? 0.0);
        });

        // Suma el precio del paquete en sí
        precio = (item.precioPaquete) + subproductosPrecio;
      }

      return sum + (precio * item.cantidad);
    });
  }

  // Cambiar modo edición y notificar para refrescar UI
  void setEditingMode(bool editing) {
    if (isEditing != editing) {
      isEditing = editing;
      _loadCart(); // esto internamente llamará notifyListeners()
      _loadEditCart();
    }
  }

/*
  // Agregar producto según modo
  void addToCart(Product product) {
    final targetList = isEditing ? _editCartItems : _cartItems;
    if (product.esProductoSencillo()) {
      // 🔹 Si es sencillo, acumula en el mismo producto
      final index = targetList.indexWhere(
        (p) => p.idProducto == product.idProducto,
      );
      if (index != -1) {
        final existing = targetList[index];
        targetList[index] = existing.copyWith(
          cantidad: existing.cantidad + product.cantidad, // 👈 acumula cantidad
          notas: product.notas.isNotEmpty ? product.notas : existing.notas,
        );
      } else {
        targetList.add(product);
      }
    } else {
      // 🔹 Si es personalizable o paquete, siempre crea una nueva instancia
      targetList.add(
        product.copyWith(
          cantidad: product.cantidad,
        ), // 👈 siempre con cantidad 1
      );
    }
    _saveCart();
    notifyListeners();
  }
  */

  // Remover producto según modo
  void removeFromCart(Product product) {
    final targetList = isEditing ? _editCartItems : _cartItems;

    targetList.removeWhere((p) => p.isSameProduct(product));

    _saveCart();
    notifyListeners();
  }

  // Limpiar según modo
  void clearCart() {
    print("Carrito en modo: " + isEditing.toString());
    // if (isEditing) {
    //   _editCartItems.clear();
    // } else {
    //   _cartItems.clear();
    // }
    _editCartItems.clear();
    _cartItems.clear();

    _saveCart();
    notifyListeners();
  }
/*
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
  */

void addToCart(Product product) {
  final targetList = isEditing ? _editCartItems : _cartItems;

  
  // Generar cartId solo si no tiene uno
  final productWithId = (product.cartId == null)
      ? product.withUniqueCartId()
      : product;

  if(product.cartId == null){
    print("es producto nuevo, creando cartid"); 
    print(productWithId); 
  }else{
    print("es cart id");
    print(product.cartId); 
  }


  // Verificar si ya existe por cartId
  final existingIndex = targetList.indexWhere((p) => p.cartId == productWithId.cartId);
  if (existingIndex != -1) {
    // Actualizar cantidad si es producto sencillo
    final existing = targetList[existingIndex];
    if (product.esProductoSencillo()) {
      targetList[existingIndex] = existing.copyWith(
        cantidad: existing.cantidad + product.cantidad,
        notas: product.notas.isNotEmpty ? product.notas : existing.notas,
      );
    } else {
      targetList[existingIndex] = productWithId; // reemplaza el producto
    }
  } else {
    targetList.add(productWithId);
  }

  _saveCart();
  notifyListeners();
}

void updateCartProduct(Product oldProduct, Product newProduct) {
  final targetList = isEditing ? _editCartItems : _cartItems;
  final index = targetList.indexWhere((p) => p.cartId == oldProduct.cartId);
  if (index != -1) {
    // Mantener cartId original
    targetList[index] = newProduct.copyWith(cartId: oldProduct.cartId);
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

  int getCartIndexByProduct(Product product) {
    final list = isEditing ? _editCartItems : _cartItems;
    return list.indexWhere((p) {
      if (p.idProducto != product.idProducto) return false;

      if (p.esProductoSencillo()) return true;

      if (p.esProductoPersonalizable()) {
        return p.opcionSeleccionada?.idProductoOpcion ==
            product.opcionSeleccionada?.idProductoOpcion;
      }

      if (p.esProductoPaquete()) {
        // Comparar subproductos seleccionados
        for (int i = 0; i < p.productos.length; i++) {
          if (p.productos[i].opcionSeleccionada?.idProductoOpcion !=
              product.productos[i].opcionSeleccionada?.idProductoOpcion) {
            return false;
          }
        }
        return true;
      }
      return false;
    });
  }

  // Reemplaza el producto en la lista según el índice
  void updateCartProductAtIndex(int index, Product product) {
    final list = isEditing ? _editCartItems : _cartItems;
    list[index] = product;
    _saveCart();
    notifyListeners();
  }

  Product? getProductFromCartByCartId(String? cartId) {
  if (cartId == null) return null;
  final targetList = isEditing ? _editCartItems : _cartItems;
  try {
    return targetList.firstWhere((p) => p.cartId == cartId);
  } catch (e) {
    return null;
  }
}

// Devuelve el índice del producto en la lista por cartId
int getCartIndexByCartId(String? cartId) {
  if (cartId == null) return -1;
  final list = isEditing ? _editCartItems : _cartItems;
  return list.indexWhere((p) => p.cartId == cartId);
}
}

extension ProductComparison on Product {
  bool isSameProduct(Product other) {
    if (idProducto != other.idProducto) return false;

    if (esProductoSencillo()) return true;

    if (esProductoPersonalizable()) {
      return opcionSeleccionada?.idProductoOpcion ==
          other.opcionSeleccionada?.idProductoOpcion;
    }

    if (esProductoPaquete()) {
      if (productos.length != other.productos.length) return false;
      for (int i = 0; i < productos.length; i++) {
        final a = productos[i].opcionSeleccionada;
        final b = other.productos[i].opcionSeleccionada;
        if ((a?.idProductoOpcion ?? 0) != (b?.idProductoOpcion ?? 0)) {
          return false;
        }
      }
      return true;
    }

    return false;
  }
}

extension ProductCartId on Product {
  Product withUniqueCartId() {
    final random = Random().nextInt(1000000); // número aleatorio pequeño
    final uniqueId = '${idProducto}_$random';
    return copyWith(cartId: uniqueId);
  }
}


