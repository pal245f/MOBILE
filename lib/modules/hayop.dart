import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // Import ScreenUtil
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:trial_mobile/models/hayop_model.dart';
import 'package:trial_mobile/utils/constants.dart';
import 'package:confetti/confetti.dart';

class lettersPage extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final int index;
  final List<Hayop> animalsItem;
  final bool isTimerEnabled;

  lettersPage({
    Key? key,
    required this.index,
    required this.animalsItem,
    required this.isTimerEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = animalsItem[index];
    return Card(
      color: item.backgroundColor,
      child: InkWell(
        onTap: () {
          _showAnimalPopup(context, AppConstants.animalsItem[index], index);
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
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
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

  Future<void> _showAnimalPopup(
      BuildContext context, Hayop animals, int currentIndex) async {
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
          animal: animals,
          audioPlayer: audioPlayer,
          animalsItem: AppConstants.animalsItem,
          flutterTts: flutterTts,
        );
      },
    );
  }
}

// ignore: must_be_immutable
class _PopupDialog extends StatefulWidget {
  final List<Hayop> animalsItem;
  int currentIndex;
  final bool isAutoNextEnabled;
  Hayop animal;
  final AudioPlayer audioPlayer;
  final FlutterTts flutterTts;

  _PopupDialog({
    Key? key,
    required this.animalsItem,
    required this.currentIndex,
    required this.isAutoNextEnabled,
    required this.animal,
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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _stopAnimalSound() async {
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
    String correctPronunciation = widget.animal.name;

    if (_recognizedWords.isEmpty) {
      _showMessageDialog(context, 'Walang naitalang boses. Subukan muli!');
      return;
    }

    if (recognizedWords.toLowerCase().trim() ==
        correctPronunciation.toLowerCase().trim()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('pronunciation_${widget.animal.name}', true);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),  // Responsive border radius
          content: Container(
            padding: EdgeInsets.zero,
            width: 0.9.sw,  // Responsive width
            decoration: BoxDecoration(
                color: widget.animal.backgroundColor,
                borderRadius: BorderRadius.circular(15.r)),
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
                            _stopAnimalSound();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () {
                            _speakAbakadaName(widget.animal.speechAsset);
                          },
                          icon: const Icon(Icons.volume_up, size: 25, color: Colors.black),
                        ),
                      ]),
                  Text(
                    widget.animal.name,
                    style: GoogleFonts.fredoka(
                      textStyle: TextStyle(
                        fontSize: 35.sp,  // Responsive font size
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
                      widget.animal.svgAsset,
                      width: 0.5.sw,  // Responsive width
                      height: 0.5.sw,  // Responsive height
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(height: 20.h),  // Responsive height
                  ElevatedButton(
                    onPressed: () {
                      _playAnimalSound(widget.animal.soundAsset);
                    },
                    child: Text(
                      'Tunog ng Hayop',
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 20.sp,  // Responsive font size
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),  // Responsive height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _navigateToPreviousAnimal,
                        icon: const Icon(
                          Icons.arrow_circle_left,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: _navigateToNextAnimal,
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
            gravity: 0.2,
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  Future<void> _playAnimalSound(String soundAsset) async {
    await widget.audioPlayer.setAsset(soundAsset);
    await widget.audioPlayer.play();
  }

  Future<void> _speakAbakadaName(String speechAsset) async {
    await widget.audioPlayer.setAsset(speechAsset);
    await widget.audioPlayer.play();
  }

  void _navigateToPreviousAnimal() {
    setState(() {
      _stopAnimalSound();
      widget.currentIndex =
          (widget.currentIndex - 1) % widget.animalsItem.length;
      if (widget.currentIndex < 0) {
        widget.currentIndex = widget.animalsItem.length - 1;
      }
      widget.animal = widget.animalsItem[widget.currentIndex];
    });
  }

  void _navigateToNextAnimal() {
    setState(() {
      _stopAnimalSound();
      widget.currentIndex =
          (widget.currentIndex + 1) % widget.animalsItem.length;
      widget.animal = widget.animalsItem[widget.currentIndex];
    });
  }
}

class hayop extends StatefulWidget {
  hayop({Key? key}) : super(key: key);

  @override
  State<hayop> createState() => _HayopState();
}

class _HayopState extends State<hayop> {
  bool isTimerEnabled = false;

  List<Hayop> items = AppConstants.animalsItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Mga Uri ng Hayop',
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
                image: AssetImage('lib/img/categ.png'), fit: BoxFit.fill)),
        child: Padding(
          padding: EdgeInsets.all(9.w),  // Responsive padding
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width ~/ 200.w,  // Responsive grid count
            childAspectRatio: 1.0,
            children: List.generate(
              items.length,
              (index) => lettersPage(
                index: index,
                animalsItem: items,
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
    builder: (context, child) => MaterialApp(home: hayop()),
  ));
}
