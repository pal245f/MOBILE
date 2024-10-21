import 'package:flutter/material.dart';
import 'package:trial_mobile/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:trial_mobile/context/user.provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.token != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/HomePage.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 30.h), // Responsive height using .h
            Container(
              height: 300.h, // Responsive height
              width: 450.w,  // Responsive width
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/img/logo1.png"),
                ),
              ),
            ),
            SizedBox(
              height: 350.h, // Responsive height
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_circle_right_sharp,
                size: 55.sp, // Responsive icon size using .sp
                color: const Color(0xfff5505b),
              ),
              onPressed: () {
                if (isLoggedIn) {
                  Navigator.pushNamed(context, AllRoutes.BottomNavRoute);
                } else {
                  Navigator.pushNamed(context, AllRoutes.BottomNavRoute);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
