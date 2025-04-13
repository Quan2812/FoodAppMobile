import 'package:flutter/material.dart';
import 'package:food_delivery/view/login/welcome_view.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});
  @override
  State<StatefulWidget> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const WelcomeView()));
  }

  // void welcomePage() {
  //   if (Globs.udValueBool(Globs.userLogin)) {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const MainTabView()));
  //   } else {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const WelcomeView()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.network(
            "https://res.cloudinary.com/do9rcgv5s/image/upload/v1692137209/e2nw6oqvtlvpqmdwtmnh.png",
            width: media.width * 0.55,
            height: media.width * 0.55,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error); // Fallback UI in case of error
            },
          ),
        ],
      ),
    );
  }
}
