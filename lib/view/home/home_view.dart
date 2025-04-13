import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../more/my_order_view.dart';
import '../../common/list.dart';
import '../menu/menu_items_view.dart'; // Import màn hình MenuItemsView
import '../../view/menu/item_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Chào buổi sáng";
    } else if (hour < 18) {
      return "Chào buổi chiều";
    } else {
      return "Chào buổi tối";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                      "${getGreeting()}${ServiceCall.userPayload[KKey.name] ?? ""} !",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Giao tới",
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Vị trí hiện tại",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 25),
                        Image.network(
                          "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811554/dropdown_z3nntl.png",
                          width: 12,
                          height: 12,
                        )
                      ],
                    )
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

              /// Giảm giá hôm nay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Giảm giá hôm nay",
                  onView: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuItemsView(
                          mObj: {"name": "Giảm giá hôm nay"},
                          items: discount,
                        ),
                      ),
                    );
                  },
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: discount.length > 3 ? 3 : discount.length,
                itemBuilder: (context, index) {
                  var pObj = discount[index] as Map? ?? {};
                  return PopularRestaurantRow(
                    pObj: pObj,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsView(item: pObj),
                        ),
                      );
                    },
                  );
                },
              ),

              /// Bán chạy nhất
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Bán chạy nhất",
                  onView: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuItemsView(
                          mObj: {"name": "Bán chạy nhất"},
                          items: mostPopArr,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: mostPopArr.length > 3 ? 3 : mostPopArr.length,
                  itemBuilder: (context, index) {
                    var mObj = mostPopArr[index] as Map? ?? {};
                    return MostPopularCell(
                      mObj: mObj,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsView(item: mObj),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// Mua gần đây
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Mua gần đây",
                  onView: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuItemsView(
                          mObj: {"name": "Mua gần đây"},
                          items: recentArr,
                        ),
                      ),
                    );
                  },
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: recentArr.length > 3 ? 3 : recentArr.length,
                itemBuilder: (context, index) {
                  var rObj = recentArr[index] as Map? ?? {};
                  return RecentItemRow(
                    rObj: rObj,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsView(item: rObj),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
