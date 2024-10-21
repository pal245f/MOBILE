import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_mobile/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:trial_mobile/context/user.provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import screenutil

const String apiUrl =
    'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getAssessments';

Future<List<Map<String, dynamic>>> fetchAssessments() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception(
          'Failed to load assessments. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching assessments: $e');
    throw Exception('Failed to fetch assessments: $e');
  }
}

class PagsasanayDashPage extends StatelessWidget {
  PagsasanayDashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, size: 24.sp), // Responsive icon size
              onPressed: () {
                Navigator.pushNamed(context, AllRoutes.BottomNavRoute);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFilteredAssessments(userProvider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Activity Available'));
          } else {
            List<Map<String, dynamic>> assessments = snapshot.data!;

            // Sort assessments by type
            assessments.sort(
                (a, b) => (a['Type'] as String).compareTo(b['Type'] as String));

            return Container(
              decoration:  BoxDecoration(
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
                      child: Image.asset("lib/img/logo1.png",
                        ), // Responsive logo height
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image:  DecorationImage(
                          image: AssetImage('lib/img/category-dash.png'),
                          fit: BoxFit.fill,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r), // Responsive radius
                          topRight: Radius.circular(30.r), // Responsive radius
                        ),
                      ),
                      padding: EdgeInsets.all(10.w), // Responsive padding
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20.h), // Responsive height
                            ...assessments.map((assessment) {
                              final String type = assessment['Type'] as String;
                              final String route = _getRouteForAssessment(type);
                              final String imageAsset =
                                  'lib/img/letters/${_getImageNameForAssessment(type)}.png';

                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: 30.h), // Responsive padding
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        20.r), // Responsive radius
                                    image: DecorationImage(
                                      image: AssetImage(imageAsset),
                                      fit: BoxFit.fill,
                                    ),
                                    color:  Color.fromARGB(
                                        255, 249, 242, 224),
                                  ),
                                  height: 150.h, // Responsive height
                                  width: 1.sw, // Full screen width
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.r), // Responsive radius
                                      ),
                                      minimumSize:
                                          Size(1.sw, 150.h), // Responsive size
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        route,
                                        arguments: {
                                          'ActivityCode':
                                              assessment['ActivityCode']
                                        },
                                      );
                                    },
                                    child: null,
                                  ),
                                ),
                              );
                            }).toList(),
                            SizedBox(
                                height:
                                    100.h), // Responsive space at the bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFilteredAssessments(
      UserProvider userProvider) async {
    List<Map<String, dynamic>> assessments = await fetchAssessments();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lrn = userProvider.user?.lrn ?? '';
    String userSection = userProvider.user?.section ?? '';

    assessments = assessments.where((assessment) {
      String activityCode = assessment['ActivityCode'] as String;
      String section = assessment['Section'] as String;

      bool isCompleted = prefs.getBool('${activityCode}_$lrn') ?? false;

      return section == userSection && !isCompleted;
    }).toList();

    return assessments;
  }

  // Return the correct route for each assessment type
  String _getRouteForAssessment(String type) {
    switch (type) {
      case 'Pagbabaybay':
        return AllRoutes.assess1Item1Route;
      case 'Pantig':
        return AllRoutes.assess2Item1Route;
      case 'Salita':
        return AllRoutes.assess3Item1Route;
      case 'Pagbabasa':
        return AllRoutes.story1Item1Route;
      default:
        return '';
    }
  }

  // Return the correct image for each assessment type
  String _getImageNameForAssessment(String type) {
    switch (type) {
      case 'Pagbabaybay':
        return 'Assessment1';
      case 'Pantig':
        return 'Assessment2';
      case 'Salita':
        return 'Assessment3';
      case 'Pagbabasa':
        return 'Assessment4';
      default:
        return 'UnknownAssessment';
    }
  }
}
