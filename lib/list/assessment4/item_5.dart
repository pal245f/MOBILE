import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trial_mobile/widgets/answer_card.dart';
import 'package:trial_mobile/widgets/next_button.dart';
import 'package:trial_mobile/screens/result_screen1.dart';

import 'package:trial_mobile/context/user.provider.dart';
import 'package:provider/provider.dart';

class Assessment4Item5 extends StatefulWidget {
  final String activityCode;

  Assessment4Item5({
    Key? key,
    required this.activityCode,
  }) : super(key: key);

  @override
  _Assessment4Item5State createState() => _Assessment4Item5State();
}

class _Assessment4Item5State extends State<Assessment4Item5> {
  String? _questions;
  String? _answer;
  List<String> _options = [];
  String? _selectedAnswer;
  int _score = 0;
  bool isLoading = true;
  int totalScore = 0;
  int storyElapsedTime = 0;
  String typeValue = "";
  String itemcode = "";

  @override
  void initState() {
    super.initState();
    fetchQuestionsAndAnswers();
    _getTotalScoreAndElapsedTime();
  }

  Future<void> _getTotalScoreAndElapsedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int scoreItem1 = prefs.getInt('scoreItem1') ?? 0;
    int scoreItem2 = prefs.getInt('scoreItem2') ?? 0;
    int scoreItem3 = prefs.getInt('scoreItem3') ?? 0;
    int scoreItem4 = prefs.getInt('scoreItem4') ?? 0;
    storyElapsedTime = prefs.getInt('story1ElapsedTime') ?? 0;

    setState(() {
      totalScore = scoreItem1 + scoreItem2 + scoreItem3 + scoreItem4;
    });

    print("Elapsed time from Story1: $storyElapsedTime seconds");
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
          typeValue = questionData['Type'] ?? 'No Type available';
          if (questionList.isNotEmpty &&
              questionList[4] is Map<String, dynamic>) {
            setState(() {
              _questions =
                  questionList[4]['Question'] ?? 'No question available';
              _answer = questionList[4]['Answer'] ?? 'No answer available';
              itemcode = questionList[4]['ItemCode'] ?? 'No ItemCode available';
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitAnswers(UserProvider userProvider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String lrn = userProvider.user?.lrn ?? '';
    if (_selectedAnswer == _answer) {
      _score = 1;
    } else {
      _score = 0;
    }

    await prefs.setInt('scoreItem5', _score);
    await prefs.setString('selectedAnswer', _selectedAnswer ?? '');

    await prefs.setBool('${widget.activityCode}_$lrn', true);
    print("Activity ${widget.activityCode} is marked as completed.");

    if (_score == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong answer! The correct answer is $_answer')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Correct answer!')));
    }

    final String activityCode = widget.activityCode;
    final String? section = userProvider.user?.section ?? '';
    final int timeRead = storyElapsedTime;
    final int score = totalScore + _score;
    final String type = typeValue;
    final String itemCode = itemcode;

    final Map<String, dynamic> performanceData = {
      'Type': type,
      'LRN': lrn,
      'Section': section,
      'ActivityCode': activityCode,
      'TimeRead': timeRead,
      'Score': score,
      'ItemCode': itemCode,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/userInputSentence'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(performanceData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseData['message'] ?? 'Data submitted successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ResultScreen(score: score, activityCode: activityCode),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${response.statusCode}. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        Text(
                          _questions ?? 'No Questions ',
                          style: GoogleFonts.fredoka(
                            textStyle: TextStyle(
                              fontSize: 30.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 420.w,
                          child: ListView.builder(
                            shrinkWrap: true,
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
                                  isSelected:
                                      _selectedAnswer == _options[index],
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
                        const SizedBox(height: 20),
                        RectangularButton(
                          onPressed: _selectedAnswer != null
                              ? () => _submitAnswers(userProvider)
                              : null,
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
