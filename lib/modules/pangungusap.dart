import 'dart:async';
import 'dart:math'; // For pi
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trial_mobile/models/pangungusap_model.dart';
import 'package:trial_mobile/utils/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class lettersPage extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final int index;
  final List<PangungusapData> pangungusapItem;
  final bool isTimerEnabled;

  lettersPage({
    Key? key,
    required this.index,
    required this.pangungusapItem,
    required this.isTimerEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = pangungusapItem[index];
    return Container(
      child: Card(
        color: item.pangungusapBG,
        child: InkWell(
          onTap: () {
            _showAnimalPopup(
                context, AppConstants.pangungusapItem[index], index);
          },
          child: Padding(
            padding: EdgeInsets.all(5.w), // Updated for responsive padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.pangungusapName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    textStyle: TextStyle(
                      fontSize: 25.sp, // Updated for responsive font size
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 3.h), // Updated for responsive spacing
                SvgPicture.asset(
                  item.pangungusapAsset,
                  width: 0.3.sw, // Updated for responsive width
                  height: 0.3.sw, // Updated for responsive height
                  alignment: Alignment.center,
                ),
                SizedBox(height: 3.h), // Updated for responsive spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAnimalPopup(BuildContext context,
      PangungusapData pangungusap, int currentIndex) async {
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
          pangungusap: pangungusap,
          audioPlayer: audioPlayer,
          pangungusapItem: AppConstants.pangungusapItem,
          flutterTts: flutterTts,
        );
      },
    );
  }
}

// ignore: must_be_immutable
class _PopupDialog extends StatefulWidget {
  final List<PangungusapData> pangungusapItem;
  int currentIndex;
  final bool isAutoNextEnabled;
  PangungusapData pangungusap;
  final AudioPlayer audioPlayer;
  final FlutterTts flutterTts;

  _PopupDialog({
    Key? key,
    required this.pangungusapItem,
    required this.currentIndex,
    required this.isAutoNextEnabled,
    required this.pangungusap,
    required this.audioPlayer,
    required this.flutterTts,
  }) : super(key: key);

  @override
  _PopupDialogState createState() => _PopupDialogState();
}

class _PopupDialogState extends State<_PopupDialog> {
  bool isTapped = false;
  bool isMicPressed = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedWords = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _confettiController = ConfettiController(
        duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _stopPangungusapSound() async {
    await widget.audioPlayer.stop();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("Hindi available ang pagkilala ng boses");
    } else {
      print("Naka-initialize ang pagkilala ng boses");
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isListening) {
      await _speech.listen(onResult: (result) {
        print("Resulta ng pagkilala ng boses: ${result.recognizedWords}");
        setState(() {
          _recognizedWords = result.recognizedWords;
        });
      });
      print("Nagsimula ng makinig...");
    } else {
      print("Naka-listen na");
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _checkPronunciation(_recognizedWords);
  }

  void _checkPronunciation(String recognizedWords) async {
    String correctPronunciation = widget.pangungusap.pangungusapName;

    print("Boses na input: " + _recognizedWords);
    print("Tama: " + correctPronunciation);

    if (_recognizedWords.isEmpty) {
      _showMessageDialog(context, 'Walang naitalang boses. Subukan muli!');
      return;
    }

    if (recognizedWords.toLowerCase().trim() ==
        correctPronunciation.toLowerCase().trim()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(
          'pronunciation_${widget.pangungusap.pangungusapName}', true);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          content: Container(
            padding: EdgeInsets.zero,
            width: 0.9.sw,
            decoration: BoxDecoration(
              color: widget.pangungusap.pangungusapBG,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _stopPangungusapSound();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: () {
                          _speakPangungusapName(widget.pangungusap.pangungusapSoundAsset);
                        },
                        icon: const Icon(Icons.volume_up, size: 25, color: Colors.black),
                      ),
                    ],
                  ),
                  Text(
                    widget.pangungusap.pangungusapName,
                    style: GoogleFonts.fredoka(
                      textStyle: TextStyle(
                        fontSize: 30.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      widget.pangungusap.pangungusapAsset,
                      width: 0.7.sw,
                      height: 0.7.sw,
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          _navigateToPreviousPangungusap();
                        },
                        icon: const Icon(
                          Icons.arrow_circle_left,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _navigateToNextPangungusap();
                        },
                        icon: const Icon(
                          Icons.arrow_circle_right,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
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
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMicPressed
                            ? Colors.redAccent.withOpacity(0.9)
                            : Colors.white.withOpacity(0.5),
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 35.sp,
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
            gravity: 0.2,
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  Future<void> _speakPangungusapName(String pariralaSound) async {
    await widget.audioPlayer.setAsset(pariralaSound);
    await widget.audioPlayer.play();
  }

  void _navigateToPreviousPangungusap() {
    setState(() {
      _stopPangungusapSound();
      widget.currentIndex =
          (widget.currentIndex - 1) % widget.pangungusapItem.length;
      if (widget.currentIndex < 0) {
        widget.currentIndex = widget.pangungusapItem.length - 1;
      }
      widget.pangungusap = widget.pangungusapItem[widget.currentIndex];
    });
  }

  void _navigateToNextPangungusap() {
    setState(() {
      _stopPangungusapSound();
      widget.currentIndex =
          (widget.currentIndex + 1) % widget.pangungusapItem.length;
      widget.pangungusap = widget.pangungusapItem[widget.currentIndex];
    });
  }
}

class pangungusapPage extends StatefulWidget {
  pangungusapPage({Key? key}) : super(key: key);

  @override
  State<pangungusapPage> createState() => _pangungusapPageState();
}

class _pangungusapPageState extends State<pangungusapPage> {
  bool isTimerEnabled = false;

  List<PangungusapData> items = AppConstants.pangungusapItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Mga Pangungusap',
              style: GoogleFonts.fredoka(
                textStyle: TextStyle(
                  fontSize: 25.sp,
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
                image: AssetImage('lib/img/categ.png'), fit: BoxFit.fill)),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width ~/ 300.w,
            childAspectRatio: 2.0,
            children: List.generate(
              items.length,
              (index) => lettersPage(
                index: index,
                pangungusapItem: items,
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
    designSize: Size(375, 812),
    builder: (context, child) => MaterialApp(home: pangungusapPage()),
  ));
}
