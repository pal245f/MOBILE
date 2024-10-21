import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trial_mobile/list/assessment4/item_5.dart';
import 'package:trial_mobile/widgets/answer_card.dart';
import 'package:trial_mobile/widgets/next_button.dart';

class Assessment4Item4 extends StatefulWidget {
  final String activityCode;

  Assessment4Item4({
    Key? key,
    required this.activityCode,
  }) : super(key: key);

  @override
  _Assessment4Item4State createState() => _Assessment4Item4State();
}

class _Assessment4Item4State extends State<Assessment4Item4> {
  String? _questions;
  String? _answer;
  List<String> _options = [];
  String? _selectedAnswer;
  int _score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestionsAndAnswers();
  }

  Future<void> fetchQuestionsAndAnswers() async {
    final questionUrl =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getActivity/${widget.activityCode}';
    final optionUrl =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getImportWord';

    try {
      final questionResponse = await http.get(Uri.parse(questionUrl));
      if (questionResponse.statusCode == 200) {
        final Map<String, dynamic> questionData =
            json.decode(questionResponse.body);

        if (questionData.containsKey('Questions') &&
            questionData['Questions'] is List<dynamic>) {
          final questionList = questionData['Questions'] as List<dynamic>;
          if (questionList.isNotEmpty &&
              questionList[3] is Map<String, dynamic>) {
            setState(() {
              _questions =
                  questionList[3]['Question'] ?? 'No question available';
              _answer = questionList[3]['Answer'] ?? 'No answer available';
            });
          } else {
            showError('No valid question found.');
          }
        } else {
          showError('Unexpected response format for questions.');
        }

        final optionResponse = await http.get(Uri.parse(optionUrl));
        if (optionResponse.statusCode == 200) {
          final dynamic optionData = json.decode(optionResponse.body);

          if (optionData is List) {
            setState(() {
              List<String> options = optionData
                  .where(
                      (option) => option is Map && option.containsKey('Word'))
                  .map<String>((option) => option['Word'].toString())
                  .toList();

              if (options.length > 3) {
                options = options.sublist(0, 3);
              }

              if (_answer != null) {
                options.add(_answer!);
                _options = options;
                _options.shuffle();
              }

              isLoading = false;
            });
          } else {
            showError('Unexpected response format for options.');
          }
        } else {
          showError(
              'Failed to load options. Status code: ${optionResponse.statusCode}');
        }
      } else {
        showError(
            'Failed to load questions. Status code: ${questionResponse.statusCode}');
      }
    } catch (e) {
      showError('Error fetching data: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _submitAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _score = _selectedAnswer == _answer ? 1 : 0;

    await prefs.setInt('scoreItem4', _score);
    await prefs.setString('selectedAnswer', _selectedAnswer ?? '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_score == 0
            ? 'Wrong answer! The correct answer is $_answer'
            : 'Correct answer!'),
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Assessment4Item5(
            activityCode: widget.activityCode,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Pagsasanay 4',
          style: GoogleFonts.fredoka(
            textStyle: TextStyle(
              fontSize: 25.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SizedBox(
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/img/assessment.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w), // Make padding responsive
                    child: Column(
                      children: [
                        SizedBox(height: 100.h), // Make height responsive
                        Text(
                          _questions ?? 'No Questions ',
                          style: GoogleFonts.fredoka(
                            textStyle: TextStyle(
                              fontSize: 30.sp, // Make font size responsive
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h), // Make height responsive
                        SizedBox(
                          width: 1.sw, // Use full width of the screen
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Prevent scrolling conflict
                            itemCount: _options.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAnswer = _options[index];
                                  });
                                },
                                child: AnswerCard(
                                  currentIndex: index,
                                  question: _options[index],
                                  isSelected: _selectedAnswer == _options[index],
                                  correctAnswerIndex:
                                      _score == 0 && _selectedAnswer != null
                                          ? _options.indexOf(_answer!)
                                          : -1,
                                  selectedAnswerIndex: index,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.h), // Make height responsive
                        RectangularButton(
                          onPressed: _selectedAnswer != null ? _submitAnswers : null,
                          label: 'Submit',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
