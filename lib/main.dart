import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:trial_mobile/models/hayop_model.dart';

import 'modules/abakada.dart';
import 'modules/alpabeto.dart';
import 'modules/hayop.dart';
import 'modules/things.dart';
import 'modules/salita.dart';
import 'modules/parirala.dart';
import 'modules/pangungusap.dart';

import 'screens/category.dart';
import 'screens/pagbabasa_dashboard.dart';
import 'screens/pagbaybay_dashboard.dart';
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/pagsasanay_dashboard.dart';

import 'package:trial_mobile/utils/routes.dart';
import 'package:trial_mobile/widgets/bottom_nav.dart';

//ASS 1 //
import 'list/assessment1/ass1_item1.dart';
import 'list/assessment1/ass1_item2.dart';
import 'list/assessment1/ass1_item3.dart';
import 'list/assessment1/ass1_item4.dart';
import 'list/assessment1/ass1_item5.dart';
import 'list/assessment1/ass1_item6.dart';
import 'list/assessment1/ass1_item7.dart';
import 'list/assessment1/ass1_item8.dart';
import 'list/assessment1/ass1_item9.dart';
import 'list/assessment1/ass1_item10.dart';

//ASS2//
import 'list/assessment2/ass2_item1.dart';
import 'list/assessment2/ass2_item2.dart';
import 'list/assessment2/ass2_item3.dart';
import 'list/assessment2/ass2_item4.dart';
import 'list/assessment2/ass2_item5.dart';
import 'list/assessment2/ass2_item6.dart';
import 'list/assessment2/ass2_item7.dart';
import 'list/assessment2/ass2_item8.dart';
import 'list/assessment2/ass2_item9.dart';
import 'list/assessment2/ass2_item10.dart';

//ASS3//
import 'list/assessment3/ass3_item1.dart';
import 'list/assessment3/ass3_item2.dart';
import 'list/assessment3/ass3_item3.dart';
import 'list/assessment3/ass3_item4.dart';
import 'list/assessment3/ass3_item5.dart';
import 'list/assessment3/ass3_item6.dart';
import 'list/assessment3/ass3_item7.dart';
import 'list/assessment3/ass3_item8.dart';
import 'list/assessment3/ass3_item9.dart';
import 'list/assessment3/ass3_item10.dart';

import 'list/assessment4/item_1.dart';
import 'list/assessment4/item_2.dart';
import 'list/assessment4/item_3.dart';
import 'list/assessment4/item_4.dart';
import 'list/assessment4/item_5.dart';
import 'list/assessment4/story1_item1.dart';

import './context/user.provider.dart';
import 'widgets/splashscreen.dart';

DateTime? currentBackPressTime;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child:  MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
   MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:  Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                scaffoldBackgroundColor:
                    const Color.fromARGB(255, 242, 226, 252),
              ),
              home: SplashScreen(), // Replace with your actual home page
              routes: {
                AllRoutes.homeRoute: (context) => HomePage(),
                AllRoutes.loginRoute: (context) => LoginPage(),
                AllRoutes.BottomNavRoute: (context) => BottomNav(),

                // CATEGORY
                AllRoutes.categoryRoute: (context) => CategoryPage(),
                AllRoutes.pagbaybayRoute: (context) => PagbaybayDashPage(),
                AllRoutes.pagsasanayDashRoute: (context) =>
                    PagsasanayDashPage(),
                AllRoutes.pagbasaDashRoute: (context) => PagbabasaDashPage(),

                // PAGBAYBAY CATEGORY
                AllRoutes.lettersRoute: (context) => aBaKaDa(),
                AllRoutes.hayopRoute: (context) => hayop(),
                AllRoutes.thingsRoute: (context) => ThingsPage(),
                AllRoutes.alpabetoRoute: (context) => alpabeto(),

                // PAGBABASA CATEGORY
                AllRoutes.salitaRoute: (context) => salitaPage(),
                AllRoutes.pariralaRoute: (context) => pariralaPage(),
                AllRoutes.pangungusapRoute: (context) => pangungusapPage(),

                // Assessment 1
                AllRoutes.assess1Item1Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item1(activityCode: activityCode);
                },
                AllRoutes.assess1Item2Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item2(activityCode: activityCode);
                },
                AllRoutes.assess1Item3Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item3(activityCode: activityCode);
                },
                AllRoutes.assess1Item4Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item4(activityCode: activityCode);
                },
                AllRoutes.assess1Item5Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item5(activityCode: activityCode);
                },
                AllRoutes.assess1Item6Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item6(activityCode: activityCode);
                },
                AllRoutes.assess1Item7Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item7(activityCode: activityCode);
                },
                AllRoutes.assess1Item8Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item8(activityCode: activityCode);
                },
                AllRoutes.assess1Item9Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item9(activityCode: activityCode);
                },
                AllRoutes.assess1Item10Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess1Item10(activityCode: activityCode);
                },

                // Assessment 2
                AllRoutes.assess2Item1Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item1(activityCode: activityCode);
                },
                AllRoutes.assess2Item2Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item2(activityCode: activityCode);
                },
                AllRoutes.assess2Item3Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item3(activityCode: activityCode);
                },
                AllRoutes.assess2Item4Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item4(activityCode: activityCode);
                },
                AllRoutes.assess2Item5Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item5(activityCode: activityCode);
                },
                AllRoutes.assess2Item6Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item6(activityCode: activityCode);
                },
                AllRoutes.assess2Item7Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item7(activityCode: activityCode);
                },
                AllRoutes.assess2Item8Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item8(activityCode: activityCode);
                },
                AllRoutes.assess2Item9Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item9(activityCode: activityCode);
                },
                AllRoutes.assess2Item10Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess2Item10(activityCode: activityCode);
                },

                // Assessment 3
                AllRoutes.assess3Item1Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item1(activityCode: activityCode);
                },
                AllRoutes.assess3Item2Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item2(activityCode: activityCode);
                },
                AllRoutes.assess3Item3Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item3(activityCode: activityCode);
                },
                AllRoutes.assess3Item4Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item4(activityCode: activityCode);
                },
                AllRoutes.assess3Item5Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item5(activityCode: activityCode);
                },
                AllRoutes.assess3Item6Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item6(activityCode: activityCode);
                },
                AllRoutes.assess3Item7Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item7(activityCode: activityCode);
                },
                AllRoutes.assess3Item8Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item8(activityCode: activityCode);
                },
                AllRoutes.assess3Item9Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item9(activityCode: activityCode);
                },
                AllRoutes.assess3Item10Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assess3Item10(activityCode: activityCode);
                },

                // Assessment 4
                AllRoutes.story1Item1Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Story1Item1Page(activityCode: activityCode);
                },
                AllRoutes.quiz1Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assessment4Item1(activityCode: activityCode);
                },
                AllRoutes.quiz2Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assessment4Item2(activityCode: activityCode);
                },
                AllRoutes.quiz3Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assessment4Item3(
                    activityCode: activityCode,
                  );
                },
                AllRoutes.quiz4Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assessment4Item4(
                    activityCode: activityCode,
                  );
                },
                AllRoutes.quiz5Route: (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final activityCode = args?['ActivityCode'] ?? '';
                  return Assessment4Item5(
                    activityCode: activityCode,
                  );
                },
              },
            );
          },
        );
      },
    );
  }
}
