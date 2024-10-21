import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trial_mobile/utils/routes.dart';
import 'package:http/http.dart' as http;

class ResultScreen2 extends StatefulWidget {
  const ResultScreen2({
    Key? key,
    required this.activityCode,
    required this.userInputId,
  }) : super(key: key);

  final String activityCode;
  final String userInputId;

  @override
  _ResultScreenState2 createState() => _ResultScreenState2();
}

class _ResultScreenState2 extends State<ResultScreen2> {
  String? _score;
  double totalScore = 0.0; // Default score

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final url =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getPerformance/${widget.userInputId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body); // Parse response as a map

        setState(() {
          _score = data['Score']?.toString() ?? 'No Score available'; // Access the score directly
          totalScore = double.tryParse(_score!) ?? 0.0;
        });
      } else {
        _showError('Failed to load activity data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching activity data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/result.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.4),  // Adjusted height for responsiveness
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: screenWidth * 0.3, // Responsive size for progress indicator
                  width: screenWidth * 0.3,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    value: (totalScore / 10).clamp(0.0, 1.0), // Ensuring value is between 0 and 1
                    color: Colors.red.shade400,
                    backgroundColor: const Color.fromARGB(255, 191, 188, 188),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      totalScore.toStringAsFixed(1),
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: screenWidth * 0.12,  // Responsive font size
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),  // Responsive spacing
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.15),  // Responsive spacing after progress indicator
            IconButton(
              icon: Icon(
                Icons.arrow_circle_right_sharp,
                size: screenWidth * 0.15,  // Responsive icon size
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
