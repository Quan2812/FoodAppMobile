import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/tab_button.dart';

import '../home/home_view.dart';
import '../menu/menu_view.dart';
import '../more/more_view.dart';
import '../profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 1;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const MenuView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20), // Dịch sang phải 10px
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              if (selctTab != 2) {
                selctTab = 2;
                selectPageView = const HomeView();
              }
              if (mounted) {
                setState(() {});
              }
            },
            shape: const CircleBorder(),
            backgroundColor:
                selctTab == 2 ? TColor.primary : TColor.placeholder,
            child: Image.network(
              "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811581/tab_home_whtxtz.png",
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: TColor.white,
        shadowColor: Colors.black,
        elevation: 1,
        notchMargin: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  title: "Trang chủ",
                  icon:
                      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811582/tab_offer_w6ab6z.png",
                  onTap: () {
                    if (selctTab != 1) {
                      selctTab = 1;
                      selectPageView = const HomeView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 1),
              TabButton(
                  title: "Menu",
                  icon:
                      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811581/tab_menu_q0ks8x.png",
                  onTap: () {
                    if (selctTab != 0) {
                      selctTab = 0;
                      selectPageView = const MenuView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 0),
              const SizedBox(
                width: 40,
                height: 40,
              ),
              TabButton(
                  title: "Hồ sơ",
                  icon:
                      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811583/tab_profile_khkma2.png",
                  onTap: () {
                    if (selctTab != 3) {
                      selctTab = 3;
                      selectPageView = const ProfileView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 3),
              TabButton(
                  title: "Khác",
                  icon:
                      "https://res.cloudinary.com/dfya8dc81/image/upload/v1738811582/tab_more_rtnivb.png",
                  onTap: () {
                    if (selctTab != 4) {
                      selctTab = 4;
                      selectPageView = const MoreView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 4),
            ],
          ),
        ),
      ),
    );
  }
}
