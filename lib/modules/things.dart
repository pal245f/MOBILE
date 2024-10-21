import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // For responsiveness
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:trial_mobile/models/things_model.dart';
import 'package:trial_mobile/utils/constants.dart';
import 'package:confetti/confetti.dart';

class lettersPage extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final int index;
  final List<Things> thingsItem;
  final bool isTimerEnabled;

  lettersPage({
    Key? key,
    required this.index,
    required this.thingsItem,
    required this.isTimerEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = thingsItem[index];
    return Card(
      color: item.backgroundColor,
      child: InkWell(
        onTap: () {
          _showThingsPopup(context, AppConstants.thingsItem[index], index);
        },
        child: Padding(
          padding: EdgeInsets.all(6.w),  // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.name,
                style: GoogleFonts.fredoka(
                  textStyle: TextStyle(
                    fontSize: 25.sp,  // Responsive font size
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),  // Responsive height
              SvgPicture.asset(
                item.svgAsset,
                width: 0.5.sw,  // Responsive width
                height: 0.5.sw,  // Responsive height
                alignment: Alignment.center,
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showThingsPopup(
      BuildContext context, Things things, int currentIndex) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setLanguage("tl-PH");
    await flutterTts.setPitch(1.5);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PopupDialog(
          currentIndex: index,
          isAutoNextEnabled: isTimerEnabled,
          things: things,
          audioPlayer: audioPlayer,
          thingsItem: AppConstants.thingsItem,
          flutterTts: flutterTts,
        );
      },
    );
  }
}

// ignore: must_be_immutable
class _PopupDialog extends StatefulWidget {
  final List<Things> thingsItem;
  int currentIndex;
  final bool isAutoNextEnabled;
  Things things;
  final AudioPlayer audioPlayer;
  final FlutterTts flutterTts;

  _PopupDialog({
    Key? key,
    required this.thingsItem,
    required this.currentIndex,
    required this.isAutoNextEnabled,
    required this.things,
    required this.audioPlayer,
    required this.flutterTts,
  }) : super(key: key);

  @override
  _PopupDialogState createState() => _PopupDialogState();
}

class _PopupDialogState extends State<_PopupDialog> {
  bool isMicPressed = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedWords = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _stopThingsSound() async {
    await widget.audioPlayer.stop();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("Speech recognition not available");
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isListening) {
      await _speech.listen(onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
        });
      });
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _checkPronunciation(_recognizedWords);
  }

  void _checkPronunciation(String recognizedWords) async {
    String correctPronunciation = widget.things.name;

    if (_recognizedWords.isEmpty) {
      _showMessageDialog(context, 'Walang naitalang boses. Subukan muli!');
      return;
    }

    if (recognizedWords.toLowerCase().trim() ==
        correctPronunciation.toLowerCase().trim()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('pronunciation_${widget.things.name}', true);

      _confettiController.play();

      await Future.wait([
        widget.audioPlayer.setAsset('assets/sounds/tama.mp3'),
        widget.audioPlayer.play(),
        Future.delayed(Duration(seconds: 1))
      ]);

      _showMessageDialog(context, 'Tamang bigkas!');
    } else {
      await widget.audioPlayer.setAsset('assets/sounds/ulitin_muli.mp3');
      await widget.audioPlayer.play();
      _showMessageDialog(context, 'Subukan muli!');
    }
  }

  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),  // Responsive border radius
          ),
          content: Container(
            padding: EdgeInsets.zero,
            width: 0.8.sw,  // Responsive width
            decoration: BoxDecoration(
              color: widget.things.backgroundColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),  // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _stopThingsSound();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: () {
                          _speakThingsName(widget.things.soundAsset);
                        },
                        icon: const Icon(Icons.volume_up, size: 25, color: Colors.black),
                      ),
                    ],
                  ),
                  Text(
                    widget.things.name,
                    style: GoogleFonts.fredoka(
                      textStyle: TextStyle(
                        fontSize: 30.sp,  // Responsive font size
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),  // Responsive height
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      widget.things.svgAsset,
                      width: 0.5.sw,  // Responsive width
                      height: 0.5.sw,  // Responsive height
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _navigateToPreviousThings,
                        icon: const Icon(
                          Icons.arrow_circle_left,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: _navigateToNextThings,
                        icon: const Icon(
                          Icons.arrow_circle_right,
                          size: 35,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),  // Responsive height
                  GestureDetector(
                    onLongPress: () async {
                      setState(() {
                        isMicPressed = true;
                      });
                      await _startListening();
                    },
                    onLongPressUp: () async {
                      await _stopListening();
                      setState(() {
                        isMicPressed = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(24.w),  // Responsive padding
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMicPressed ? Colors.redAccent.withOpacity(0.9) : Colors.white.withOpacity(0.5),
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 35.w,  // Responsive icon size
                        color: isMicPressed ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Future<void> _speakThingsName(String soundAsset) async {
    await widget.audioPlayer.setAsset(soundAsset);
    await widget.audioPlayer.play();
  }

  void _navigateToPreviousThings() {
    setState(() {
      _stopThingsSound();
      widget.currentIndex =
          (widget.currentIndex - 1) % widget.thingsItem.length;
      if (widget.currentIndex < 0) {
        widget.currentIndex = widget.thingsItem.length - 1;
      }
      widget.things = widget.thingsItem[widget.currentIndex];
    });
  }

  void _navigateToNextThings() {
    setState(() {
      _stopThingsSound();
      widget.currentIndex =
          (widget.currentIndex + 1) % widget.thingsItem.length;
      widget.things = widget.thingsItem[widget.currentIndex];
    });
  }
}

class ThingsPage extends StatefulWidget {
  ThingsPage({Key? key}) : super(key: key);

  @override
  State<ThingsPage> createState() => _ThingsPageState();
}

class _ThingsPageState extends State<ThingsPage> {
  bool isTimerEnabled = false;
  List<Things> items = AppConstants.thingsItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Mga Uri ng Bagay',
              style: GoogleFonts.fredoka(
                textStyle: TextStyle(
                  fontSize: 25.sp,  // Responsive font size
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/categ.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(9.w),  // Responsive padding
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width ~/ 200.w,  // Responsive grid
            childAspectRatio: 1.0,
            children: List.generate(
              items.length,
              (index) => lettersPage(
                index: index,
                thingsItem: items,
                isTimerEnabled: isTimerEnabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(ScreenUtilInit(
    designSize: Size(375, 812),  // Design size for scaling
    builder: (context, child) => MaterialApp(home: ThingsPage()),
  ));
}
