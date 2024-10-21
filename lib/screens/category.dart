import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_mobile/context/user.provider.dart';
import 'package:trial_mobile/utils/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CategoryPage extends StatelessWidget {
  CategoryPage({super.key});

  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.token != null;

    Future<void> nextPage() async {
      if (isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
              context, AllRoutes.pagsasanayDashRoute);
        });
      } else {
        Navigator.pushReplacementNamed(context, AllRoutes.loginRoute);
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
        backgroundColor: const Color.fromARGB(0, 144, 84, 84),
        elevation: 0,
        actions: [
          if (isLoggedIn)
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w), // Responsive padding
              child: GestureDetector(
                onTap: () {
                  userProvider.logout();
                  Navigator.pushReplacementNamed(context, AllRoutes.homeRoute);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 54, 79, 244),
                    borderRadius:
                        BorderRadius.circular(10.r), // Responsive border radius
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 5.h, // Responsive vertical padding
                      horizontal: 12.w // Responsive horizontal padding
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      SizedBox(
                          width: 8.w), // Responsive space between icon and text
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/categ.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 200.h,
              width: 350.w,
              child: Center(
                child: Image.asset(
                  "lib/img/logo1.png",
                ), // Responsive logo height
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/img/category-dash.png'),
                    fit: BoxFit.fill,
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r), // Responsive radius
                    topRight: Radius.circular(30.r), // Responsive radius
                  ),
                ),
                padding: EdgeInsets.all(10.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h), // Responsive height
                      buildButton(
                        context,
                        'lib/img/syllables.png',
                        AllRoutes.pagbaybayRoute,
                      ),
                      SizedBox(height: 20.h), // Responsive height
                      buildButton(
                        context,
                        'lib/img/read.png',
                        AllRoutes.pagbasaDashRoute,
                      ),
                      SizedBox(height: 20.h), // Responsive height
                      buildButton(
                        context,
                        'lib/img/quiz.png',
                        null, // Will call nextPage()
                        onTap: nextPage,
                      ),
                      SizedBox(height: 20.h), // Responsive height
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String imagePath, String? route,
      {Function? onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r), // Responsive border radius
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.fill,
        ),
        color: Color(0xfff5505b),
      ),
      height: 150.h, // Responsive height
      width: 450.w, // Responsive width
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20.r), // Responsive border radius
            ),
          ),
          minimumSize:
              WidgetStateProperty.all(Size(450.w, 150.h)), // Responsive size
        ),
        onPressed: () {
          if (onTap != null) {
            onTap();
          } else if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
        child: Text(''),
      ),
    );
  }
}
