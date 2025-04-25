import 'package:flutter/material.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../home/home_view.dart';
import '../main_tabview/main_tabview.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  void initState() {
    super.initState();
    // Gọi API xóa giỏ hàng ngay khi màn hình được tải
    serviceCallRemoveCart();
  }

  void serviceCallRemoveCart() {
    // Globs.showHUD();
    ServiceCall.get(
      "Cart/remove-cart/1"
    );
    // Globs.hideHUD();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     IconButton(
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       icon: Icon(
          //         Icons.close,
          //         color: TColor.primaryText,
          //         size: 25,
          //       ),
          //     ),
          //   ],
          // ),
          Image.network(
            "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811583/thank_you_xmc02i.png",
            width: media.width * 0.55,
          ),
          const SizedBox(height: 200),
          Text(
            "Đặt hàng thành công!",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   "Đơn hàng của bạn hiện đang được xử lý. Chúng tôi sẽ thông báo cho bạn khi đơn hàng được lấy từ cửa hàng. Kiểm tra trạng thái Đơn hàng của bạn",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(color: TColor.primaryText, fontSize: 14),
          // ),
          // const SizedBox(height: 35),
          // RoundButton(
          //   title: "Kiểm tra đơn hàng",
          //   onPressed: () {
          //     // TODO: Thêm logic chuyển hướng đến màn hình kiểm tra đơn hàng
          //   },
          // ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainTabView()));
            },
            child: Text(
              "Quay về Trang chủ",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}