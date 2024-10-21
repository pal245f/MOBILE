import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RectangularButton extends StatelessWidget {
  const RectangularButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: SizedBox(
        height: 50.h, // Make height responsive
        width: 250.w, // Make width responsive
        child: Card(
          color: onPressed != null ? const Color(0xfff5505b) : null,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                textStyle: TextStyle(
                  fontSize: 25.sp, // Make font size responsive
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
