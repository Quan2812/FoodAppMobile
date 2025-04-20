import 'package:flutter/material.dart';
import 'package:food_delivery/common/globs.dart';
import '../common/service_call.dart';
import '../models/product.dart';


class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(
      Product product,
      int qty,
      int isAdd,
      {Function(String success)? onSuccess, Function(String error)? onError}
      ) {
    Globs.showHUD();
    ServiceCall.post(
        "cart",
        {
          "productId": product.productId,
          "quantity": qty,
          "userId": Globs.udValueInt(KKey.userId),
          "isAdd": isAdd
        },
        isToken: true,
        withSuccess: (responseObj) async {
          print("res add caet ${responseObj}");
          Globs.hideHUD();
          if (responseObj.isNotEmpty) {
            if (onSuccess != null) onSuccess("Thêm sản phẩm thành công");  // báo cho UI
          } else {
            if (onError != null) onError(responseObj["message"] ?? "Thêm sản phẩm thất bại");
          }
        },
        failure: (err) async {
          Globs.hideHUD();
          if (onError != null) onError(err.toString());
        }
    );
  }


  void removeItem(int productId) async {
    ServiceCall.post(
      "cart/remove",
      {
        "productId": productId,
      },
      isToken: true,
      withSuccess: (responseObj) async {
        if (responseObj["success"] == true) {
          _items.removeWhere((item) => item['product'].productId == productId);
          notifyListeners();
        } else {
          throw responseObj["message"] ?? "Xoá sản phẩm thất bại!";
        }
      },
      failure: (error) async {
        throw error.toString();
      },
    );
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems =>
      _items.fold(0, (total, item) => total + (item['qty'] as int));

  double get totalPrice => _items.fold(
      0.0,
          (total, item) =>
      total + (item['product'].price as double) * (item['qty'] as int));
}
