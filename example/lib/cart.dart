import 'package:data_widget/data_widget.dart';
import 'package:flutter/foundation.dart';

import 'product.dart';

class CartManager {
  final MapNotifier<Product, int> _cartItems = MapNotifier();

  Future<void> addToCart(Product product, [int quantity = 1]) async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    _cartItems.update(product, (value) => value + quantity,
        ifAbsent: () => quantity);
  }

  Future<void> changeQuantity(Product product, int quantity) async {
    if (quantity == 0) {
      await removeFromCart(product);
      return;
    }
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    _cartItems.update(product, (value) => quantity, ifAbsent: () => quantity);
  }

  Future<void> removeFromCart(Product product) async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    _cartItems.remove(product);
  }

  ValueListenable<Map<Product, int>> get cartItemsListenable => _cartItems;
}
