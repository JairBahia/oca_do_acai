import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

//ChangeNotifier
class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  // Adiciona item ou incrementa quantidade se já existir
  void addItem(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  // Remove o item completamente do carrinho
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Decrementa a quantidade; remove se chegar a zero
  void decreaseQuantity(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Limpa o carrinho após finalizar o pedido
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
