import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.currentIndex,
    required this.correctAnswerIndex,
    required this.selectedAnswerIndex,
  });

  final String question;
  final bool isSelected;
  final int? correctAnswerIndex;
  final int? selectedAnswerIndex;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    bool isCorrectAnswer = currentIndex == correctAnswerIndex;
    bool isWrongAnswer = !isCorrectAnswer && isSelected;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.h, // Make vertical padding responsive
      ),
      child: selectedAnswerIndex != null
          ? Container(
              height: 70.h, // Make height responsive
              padding: EdgeInsets.all(10.w), // Make padding responsive
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10.r), // Make border radius responsive
                border: Border.all(
                  color: isCorrectAnswer
                      ? Colors.green
                      : isWrongAnswer
                          ? Colors.red
                          : Colors.white,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 20.sp, // Make font size responsive
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h), // Use responsive height
                  isCorrectAnswer
                      ? buildCorrectIcon()
                      : isWrongAnswer
                          ? buildWrongIcon()
                          : const SizedBox.shrink(),
                ],
              ),
            )
          : Container(
              height: 70.h, // Make height responsive
              padding: EdgeInsets.all(16.w), // Make padding responsive
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r), // Make border radius responsive
                border: Border.all(
                  color: Colors.blue.shade700,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 20.sp, // Make font size responsive
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
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

Widget buildCorrectIcon() => CircleAvatar(
      radius: 15.r, // Make radius responsive
      backgroundColor: Colors.green,
      child: const Icon(
        Icons.check,
        color: Colors.white,
      ),
    );

Widget buildWrongIcon() => CircleAvatar(
      radius: 15.r, // Make radius responsive
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.close,
        color: Colors.white,
      ),
    );
