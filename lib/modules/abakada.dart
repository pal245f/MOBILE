import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // For screen responsiveness
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_mobile/models/abakada_model.dart';
import 'package:trial_mobile/utils/constants.dart';
import 'package:confetti/confetti.dart';

class LettersPage extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final int index;
  final List<AbakadaData> abakadaItems;
  final bool isTimerEnabled;

  LettersPage({
    Key? key,
    required this.index,
    required this.abakadaItems,
    required this.isTimerEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = abakadaItems[index];
    return Card(
      color: item.abakadaBG,
      child: InkWell(
        onTap: () {
          _showAnimalPopup(context, abakadaItems[index], index);
        },
        child: Padding(
          padding: EdgeInsets.all(6.w),  // Using ScreenUtil for padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 3.h),  // Adjust height
              SvgPicture.asset(
                item.abakadaAsset,
                width: 0.5.sw,  // Use screen width scaling
                height: 0.5.sw,
                alignment: Alignment.center,
              ),
              SizedBox(height: 3.h),  // Adjust height
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAnimalPopup(
      BuildContext context, AbakadaData abakada, int currentIndex) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setLanguage("tl-PH"); // Set to Tagalog
    await flutterTts.setPitch(1.5);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PopupDialog(
          currentIndex: index,
          isAutoNextEnabled: isTimerEnabled,
          abakada: abakada,
          audioPlayer: audioPlayer,
          abakadaItems: abakadaItems,
          flutterTts: flutterTts,
        );
      },
    );
  }
}

// ignore: must_be_immutable
class _PopupDialog extends StatefulWidget {
  final List<AbakadaData> abakadaItems;
  int currentIndex;
  final bool isAutoNextEnabled;
  AbakadaData abakada;
  final AudioPlayer audioPlayer;
  final FlutterTts flutterTts;

  _PopupDialog({
    Key? key,
    required this.abakadaItems,
    required this.currentIndex,
    required this.isAutoNextEnabled,
    required this.abakada,
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

  Future<void> _stopAbakadaSound() async {
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
    String correctPronunciation = widget.abakada.abakadaTitle;

    if (_recognizedWords.isEmpty) {
      _showMessageDialog(context, 'Walang naitalang boses. Subukan muli!');
      return;
    }

    if (recognizedWords.toLowerCase().trim() ==
        correctPronunciation.toLowerCase().trim()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('pronunciation_${widget.abakada.abakadaTitle}', true);

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
      alignment: Alignment.center,
      children: [
        AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          content: Container(
            padding: EdgeInsets.zero,
            width: 0.8.sw,
            decoration: BoxDecoration(
                color: widget.abakada.abakadaBG,
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
                            _stopAbakadaSound();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back,
                              size: 25, color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () {
                            _speakAbakadaName(widget.abakada.abakadaSoundAsset);
                          },
                          icon: Icon(Icons.volume_up,
                              size: 25, color: Colors.black),
                        ),
                      ]),
                  SizedBox(height: 20.h),  // Responsive spacing
                  GestureDetector(
                    onTap: () {},
                    child: SvgPicture.asset(
                      widget.abakada.abakadaAsset,
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
                        onPressed: _navigateToPreviousAbakada,
                        icon: const Icon(Icons.arrow_circle_left,
                            size: 35, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: _navigateToNextAbakada,
                        icon: const Icon(Icons.arrow_circle_right,
                            size: 35, color: Colors.black),
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
                      padding: EdgeInsets.all(24.w),  // Responsive padding
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMicPressed
                            ? Colors.redAccent.withOpacity(0.9)
                            : Colors.white.withOpacity(0.5),
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
            blastDirection: -3.14 / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  Future<void> _speakAbakadaName(String abakadaSoundAsset) async {
    await widget.audioPlayer.setAsset(abakadaSoundAsset);
    await widget.audioPlayer.play();
  }

  void _navigateToPreviousAbakada() {
    setState(() {
      _stopAbakadaSound();
      widget.currentIndex =
          (widget.currentIndex - 1) % widget.abakadaItems.length;
      if (widget.currentIndex < 0) {
        widget.currentIndex = widget.abakadaItems.length - 1;
      }
      widget.abakada = widget.abakadaItems[widget.currentIndex];
    });
  }

  void _navigateToNextAbakada() {
    setState(() {
      _stopAbakadaSound();
      widget.currentIndex =
          (widget.currentIndex + 1) % widget.abakadaItems.length;
      widget.abakada = widget.abakadaItems[widget.currentIndex];
    });
  }
}

class aBaKaDa extends StatefulWidget {
  aBaKaDa({Key? key}) : super(key: key);

  @override
  State<aBaKaDa> createState() => _aBaKaDaState();
}

class _aBaKaDaState extends State<aBaKaDa> {
  bool isTimerEnabled = false;
  List<AbakadaData> items = AppConstants.abakadaItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'aBaKaDa',
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
            crossAxisCount: (MediaQuery.of(context).size.width ~/ 200.w),  // Responsive grid
            childAspectRatio: 1.0,
            children: List.generate(
              items.length,
              (index) => LettersPage(
                index: index,
                abakadaItems: items,
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
    designSize: Size(375, 812), // Design size for scaling
    minTextAdapt: true,
    builder: (context, child) => MaterialApp(home: aBaKaDa()),
  ));
}
