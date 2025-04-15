import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common/list.dart';
import 'package:intl/intl.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  List<dynamic> cardItems = [];
  bool isLoading = true;
  double subtotal = 0;

  @override
  void initState() {
    super.initState();
    serviceGetCard();
  }

  /// Gọi API lấy giỏ hàng
  void serviceGetCard() {
    Globs.showHUD();
    var user_id = Globs.udValueString(KKey.userId) ?? "0";
    print("Begin call api getCard:");
    ServiceCall.get("Cart/${user_id}",
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          print("Cart: ${responseObj.toString()}");
          if (responseObj.isNotEmpty) {
            setState(() {
              cardItems = responseObj["data"] ?? [];
              isLoading = false;
              subtotal = getSubtotal(cardItems);
            });
          } else {
            setState(() => isLoading = false);
            mdShowAlert(
                Globs.appName,
                responseObj[KKey.message] as String? ?? "Không tìm thấy giỏ hàng",
                    () {});
          }
        },
        failure: (err) async {
          Globs.hideHUD();
          setState(() => isLoading = false);
          mdShowAlert(Globs.appName, err.toString(), () {});
        });
  }

  /// Tính tổng tạm tính
  double getSubtotal(List<dynamic> itemArr) {
    double subtotal = 0;
    for (var item in itemArr) {
      var price = item["price"] ?? 0;
      var qty = item["quantity"] ?? 0;
      subtotal += price * qty;
    }
    return subtotal;
  }

  /// API để thêm sản phẩm mới
  void serviceAddItem(Map<String, dynamic> newItem) {
    Globs.showHUD();
    var user_id = Globs.udValueString(KKey.userId) ?? "0";
    ServiceCall.post("Cart/${user_id}/add", newItem,
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          serviceGetCard(); // Refresh cart after adding
        },
        failure: (err) async {
          Globs.hideHUD();
          mdShowAlert(Globs.appName, err.toString(), () {});
        });
  }

  /// API để cập nhật số lượng sản phẩm
  void serviceUpdateQuantity(String itemId, int newQuantity, String IsAdd) {
    Globs.showHUD();
    var user_id = Globs.udValueString(KKey.userId) ?? "0";
    ServiceCall.get("Cart/update-cart-item/${itemId}/${user_id}/${newQuantity}/${IsAdd}",
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          serviceGetCard(); // Refresh cart after updating
        },
        failure: (err) async {
          Globs.hideHUD();
          mdShowAlert(Globs.appName, err.toString(), () {});
        });
  }

  /// API để xóa sản phẩm
  void serviceDeleteItem(String itemId, String quantity) {
    Globs.showHUD();
    var user_id = Globs.udValueString(KKey.userId) ?? "0";
    ServiceCall.get("Cart/update-cart-item/${itemId}/${user_id}/${quantity}/0",
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          serviceGetCard(); // Refresh cart after deleting
        },
        failure: (err) async {
          Globs.hideHUD();
          mdShowAlert(Globs.appName, err.toString(), () {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.network(
                          "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811555/btn_back_bchrbu.png",
                          width: 20,
                          height: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Giỏ hàng",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            "https://res.cloudinary.com/do9rcgv5s/image/upload/v1692137209/e2nw6oqvtlvpqmdwtmnh.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: cardItems.length,
                  separatorBuilder: ((context, index) => Divider(
                    indent: 25,
                    endIndent: 25,
                    color: TColor.secondaryText.withOpacity(0.5),
                    height: 1,
                  )),
                  itemBuilder: ((context, index) {
                    var cObj = cardItems[index] as Map? ?? {};
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${cObj["name"].toString()}",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        int currentQty = cObj["quantity"] ?? 1;
                                        if (currentQty > 1) {
                                          serviceUpdateQuantity(
                                              cObj["id"].toString(),
                                              1, "0");
                                        }
                                      },
                                      icon: Icon(Icons.remove,
                                          size: 20, color: TColor.primary),
                                    ),
                                    Text(
                                      "${cObj["quantity"].toString()}",
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        int currentQty = cObj["quantity"] ?? 1;
                                        serviceUpdateQuantity(
                                            cObj["id"].toString(),
                                            1, "1");
                                      },
                                      icon: Icon(Icons.add,
                                          size: 20, color: TColor.primary),
                                    ),
                                    const SizedBox(width: 140),
                                    Text(
                                      ("${NumberFormat("#,###", "vi_VN").format(cObj["price"] * cObj["quantity"])}"),
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        serviceDeleteItem(cObj["id"].toString(), cObj["quantity"]);
                                      },
                                      icon: Icon(Icons.delete,
                                          size: 20, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),


                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tạm tính",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          ("${NumberFormat("#,###", "vi_VN").format(subtotal)}"),
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    RoundButton(
                        title: "Thanh toán",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutView(subtotal: subtotal),
                            ),
                          );
                        }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}