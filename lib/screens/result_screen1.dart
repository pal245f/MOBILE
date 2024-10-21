import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_mobile/utils/routes.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key, required this.activityCode, required int score})
      : super(key: key);

  final String activityCode;

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve scores from SharedPreferences for item1 to item5
    int scoreItem1 = prefs.getInt('scoreItem1') ?? 0;
    int scoreItem2 = prefs.getInt('scoreItem2') ?? 0;
    int scoreItem3 = prefs.getInt('scoreItem3') ?? 0;
    int scoreItem4 = prefs.getInt('scoreItem4') ?? 0;
    int scoreItem5 = prefs.getInt('scoreItem5') ?? 0;

    setState(() {
      totalScore = scoreItem1 + scoreItem2 + scoreItem3 + scoreItem4 + scoreItem5;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/result.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.4),  // Adjusting for screen height
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: screenWidth * 0.3,  // Responsive size
                  width: screenWidth * 0.3,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    value: totalScore / 5, // Assuming each item has a maximum score of 1
                    color: Colors.red.shade400,
                    backgroundColor: const Color.fromARGB(255, 191, 188, 188),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      totalScore.toString(),
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: screenWidth * 0.12, // Responsive font size
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01), // Responsive space
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.15), // Adjusted spacing
            IconButton(
              icon: Icon(
                Icons.arrow_circle_right_sharp,
                size: screenWidth * 0.15, // Responsive icon size
                color: const Color(0xff7668d2),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AllRoutes.BottomNavRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
