import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trial_mobile/utils/routes.dart';

class Story1Item1Page extends StatefulWidget {
  final String activityCode;

  Story1Item1Page({Key? key, required this.activityCode}) : super(key: key);

  @override
  _Story1Item1PageState createState() => _Story1Item1PageState();
}

class _Story1Item1PageState extends State<Story1Item1Page> {
  late Timer _timer;
  int _elapsedTime = 0;
  String? _storyText;
  String? _titleText;

  @override
  void initState() {
    super.initState();
    fetchStoryData();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  void stopTimer() async {
    _timer.cancel();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('story1ElapsedTime', _elapsedTime);
    print("Elapsed time saved: $_elapsedTime seconds");
  }

  Future<void> fetchStoryData() async {
    final url =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getActivity/${widget.activityCode}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _storyText = data['Sentence'];
          _titleText = data['Title'];
        });
      } else {
        showError('Failed to load story. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching story data: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/assessment.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 25.h),
            Container(
              height: 200.h,
              width: 350.w,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("lib/img/logo1.png")),
              ),
            ),
            Container(
              height: 390.h,
              width: 360.w,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Color(0xFF004380),
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 15.h),
                  Text(
                    _titleText ?? 'Loading Title',
                    style: GoogleFonts.fredoka(
                      textStyle: TextStyle(
                        fontSize: 25.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    padding: EdgeInsets.all(15.w),
                    child: Text(
                      _storyText ?? 'Loading story...',
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            MaterialButton(
              onPressed: () {
                stopTimer();
                Navigator.pushNamed(
                  context,
                  AllRoutes.quiz1Route,
                  arguments: {'ActivityCode': widget.activityCode},
                );
              },
              color: Color(0xfff5505b),
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 130.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "Sunod",
                style: GoogleFonts.fredoka(
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
