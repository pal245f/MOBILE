import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trial_mobile/screens/homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  get splash => null;
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child:
                LottieBuilder.asset('lib/img/Animation - 1726153316030.json'),
          )
        ],
      ),
      nextScreen: HomePage(),
      splashIconSize: 400.sp,
      backgroundColor: Colors.white,
    );
  }
}
