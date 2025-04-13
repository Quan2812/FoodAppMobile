import 'package:flutter/material.dart';
import 'package:food_delivery/common/extension.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../more/my_order_view.dart';
import 'menu_items_view.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  TextEditingController txtSearch = TextEditingController();
  List<dynamic> menuList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    serviceCallMenu();
  }

  /// Gọi API lấy danh sách menu
  void serviceCallMenu() {
    Globs.showHUD();

    ServiceCall.get("ProductType",
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          print("List menu: ${responseObj["data"]?["data"]} ${responseObj["statusCode"]}");
          var statusCode = responseObj["statusCode"];
          if (statusCode == 200) {
            setState(() {
              menuList = responseObj["data"]?["data"] ?? [];
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
            mdShowAlert(
                Globs.appName,
                responseObj[KKey.message] as String? ?? "Tải menu thất bại!",
                    () {}
            );
          }
        },
        failure: (err) async {
          Globs.hideHUD();
          setState(() => isLoading = false);
          mdShowAlert(Globs.appName, err.toString(), () {});
        }
    );
  }

  /// Hàm hiển thị ảnh
  Widget imageWidget(String imagePath) {
    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 180),
            width: media.width * 0.27,
            height: media.height * 0.6,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
            ),
          ),

          // Nội dung
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 46),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Menu",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyOrderView()));
                          },
                          icon: Image.network(
                            "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811580/shopping_cart_kpv8em.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RoundTextfield(
                      hintText: "Tìm món ăn",
                      controller: txtSearch,
                      left: Container(
                        alignment: Alignment.center,
                        width: 30,
                        child: Image.network(
                          "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811579/search_cw3ct1.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  isLoading
                      ? const CircularProgressIndicator() // Nếu đang loading
                      : menuList.isEmpty
                      ? const Text("Không có dữ liệu menu.")
                      : ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 500,  // <<< chỉnh chiều cao tối thiểu tùy mong muốn
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: menuList.length,
                      itemBuilder: (context, index) {
                        var mObj = menuList[index] as Map? ?? {};
                        print("List sản phẩm của danh mục: ${mObj["products"]}");
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuItemsView(
                                  mObj: mObj,
                                  items: mObj["products"] ?? [],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 8, bottom: 8, right: 20),
                                width: media.width - 100,
                                height: 90,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 7,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  imageWidget(mObj["imageTypeProduct"].toString()),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mObj["nameProductType"].toString(),
                                          style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${mObj["products"].length} items",
                                          style: TextStyle(
                                            color: TColor.secondaryText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(17.5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.network(
                                      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811556/btn_next_nmumbw.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
