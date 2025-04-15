import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Product product, int qty) {
    // Kiểm tra trùng lặp dựa trên productId
    final existingItemIndex =
    _items.indexWhere((item) => item['product'].productId == product.productId);

    if (existingItemIndex != -1) {
      // Nếu đã có, tăng số lượng
      _items[existingItemIndex]['qty'] = (_items[existingItemIndex]['qty'] as int) + qty;
    } else {
      // Nếu chưa có, thêm mới
      _items.add({'product': product, 'qty': qty});
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item['product'].productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Tính tổng số lượng sản phẩm
  int get totalItems =>
      _items.fold(0, (total, item) => total + (item['qty'] as int));

  // Tính tổng giá tiền
  double get totalPrice => _items.fold(
      0.0,
          (total, item) =>
      total + (item['product'].price as double) * (item['qty'] as int));
}