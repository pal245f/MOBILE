import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class PagbabasaDashPage extends StatelessWidget {
  PagbabasaDashPage({super.key});

  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: [
              Text(
                '',
                style: GoogleFonts.fredoka(
                  textStyle: TextStyle(
                    fontSize: 25,
                    color: Color(0xffa459d1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('lib/img/categ.png'), 
                    fit: BoxFit.fill
                    ),
                    ),
            child:  Column(
              children: [
                Container(
                        height: 200.h,
                        width: 350.w,
                        child: Center(
                      child: Image.asset("lib/img/logo1.png",
                         ), // Responsive logo height
                    ),
                      ),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('lib/img/category-dash.png'),
                                fit: BoxFit.fill
                                ),
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.r),
                              topRight: Radius.circular(30.r),
                            ),
                            ),
                         padding: EdgeInsets.all(10.w), // Responsive padding
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 20.h), // Responsive height
                              buildButton(
                                context,
                                'lib/img/letters/salita.png',
                                AllRoutes.salitaRoute,
                              ),
                              SizedBox(height: 20.h), // Responsive height
                              buildButton(
                                context,
                                'lib/img/letters/parirala.png',
                                AllRoutes.pariralaRoute,
                              ),
                              SizedBox(height: 20.h), // Responsive height
                              buildButton(
                                context,
                                'lib/img/letters/pangungusap.png',
                                AllRoutes.pangungusapRoute,
                              ),
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
