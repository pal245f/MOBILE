import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:localstorage/localstorage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_mobile/utils/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Assess2Item5 extends StatefulWidget {
  final String activityCode;

  Assess2Item5({Key? key, required this.activityCode}) : super(key: key);

  @override
  _Assess2Item5State createState() => _Assess2Item5State();
}

class _Assess2Item5State extends State<Assess2Item5> {
  late FlutterSoundRecorder _recordingSession;
  late String _pathToAudio;
  bool _isRecording = false;
  bool _isRecordingComplete = false;
  bool _isAudioSent = false; 
  String? _imageUrl;
  late String _itemcode;
  String? _getword;

  @override
  void initState() {
    super.initState();
    initialize();
    fetchActivityData();
  }

  @override
  void dispose() {
    _recordingSession.closeAudioSession();
    super.dispose();
  }

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _pathToAudio = path.join(directory.path, 'temp_${widget.activityCode}.wav');

    _recordingSession = FlutterSoundRecorder();

    await Permission.microphone.request();
    await Permission.storage.request();

    await _recordingSession.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await _recordingSession.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  Future<void> fetchActivityData() async {
    final url =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getActivity/${widget.activityCode}';

    print('Code: ${widget.activityCode}');
    await initLocalStorage();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          final itemCode = data['Items'] as List<dynamic>;
          _itemcode = itemCode.isNotEmpty ? itemCode[4]['ItemCode'] : 'No Code';

          final word = data['Items'] as List<dynamic>;
          _getword = word.isNotEmpty ? itemCode[4]['Word'] : 'No Word';

          final items = data['Items'] as List<dynamic>;
          _imageUrl = items.isNotEmpty
              ? items[4]['Image']
              : 'https://via.placeholder.com/150';
        });

        print(_itemcode);
      } else {
        showError(
            'Failed to load activity data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching activity data: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Pagsasanay 2',
          style: GoogleFonts.fredoka(
            textStyle: TextStyle(
              fontSize: 25.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/assessment.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
             height: 490.h,
              width: 370.w,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Color(0xFF004380),
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:  EdgeInsets.all(10.w),
                    child: Text(
                      'Bigkasin ng tama ang pantig na ito:',
                      style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 19.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text( '${_getword ?? ' No Word'}',
                   style: GoogleFonts.fredoka(
                        textStyle: TextStyle(
                          fontSize: 30.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ),
                  SizedBox(height: 10.h,),
                 Container(
                    width: 250.w,
                    height: 250.h,
                    child: _imageUrl != null
                        ? (_imageUrl!.endsWith('.svg')
                            ? SvgPicture.network(_imageUrl!, fit: BoxFit.cover)
                            : Image.network(_imageUrl!, fit: BoxFit.cover))
                        : Center(child: Text('Image not available')),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (!_isRecording && !_isRecordingComplete) ...[
                        _buildElevatedButton(
                          icon: Icons.mic,
                          iconColor: Colors.red,
                          label: 'Salita',
                          onPressFunc: startRecording,
                        ),
                      ] else if (_isRecording) ...[
                        _buildElevatedButton(
                          icon: Icons.stop,
                          iconColor: Colors.red,
                          label: 'Tigil',
                          onPressFunc: stopRecording,
                        ),
                      ] else if (_isRecordingComplete) ...[
                        _buildElevatedButton(
                          icon: Icons.send_rounded,
                          iconColor: Colors.white,
                          label: 'Ipasa',
                          onPressFunc: sendAudio,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            MaterialButton(
              onPressed: () {
                if (_isAudioSent) {
                  // Only proceed if audio is sent
                  Navigator.pushNamed(
                    context,
                    AllRoutes.assess2Item6Route,
                    arguments: {'ActivityCode': widget.activityCode},
                  );
                } else {
                  // Show error if the audio hasn't been sent
                  showError('Pakilagay ang pinagtalang salita bago sumunod.');
                }
              },
              color: Color(0xfff5505b),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 130),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                "Sunod",
                style: GoogleFonts.fredoka(
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildElevatedButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    VoidCallback? onPressFunc,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6.0),
        side: BorderSide(color: Colors.blue.shade400, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        minimumSize: Size(125.w, 40.h),
        backgroundColor: Colors.blue.shade400,
      ),
      onPressed: onPressFunc,
      icon: Icon(icon, color: iconColor, size: 25.sp),
      label: Text(label, style: TextStyle(fontSize: 18.sp, color: Colors.white)),
    );
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.isGranted) {
      Directory directory = await getApplicationDocumentsDirectory();
      _pathToAudio =
          path.join(directory.path, 'temp_${widget.activityCode}_item5.wav');

      if (!Directory(path.dirname(_pathToAudio)).existsSync()) {
        Directory(path.dirname(_pathToAudio)).createSync(recursive: true);
      }

      await _recordingSession.startRecorder(
        toFile: _pathToAudio,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
      });
    } else {
      showError('Microphone permission is required to record audio.');
    }
  }

  Future<void> stopRecording() async {
    await _recordingSession.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecordingComplete = true; // Indicate recording is complete
    });
  }

  Future<void> sendAudio() async {
    if (_pathToAudio.isEmpty) {
      showError('No audio file to upload.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Save the file path and item code
      await prefs.setString('User5', _pathToAudio); // Save the file path
      await prefs.setString('ItemCode5', _itemcode); // Save the item code
      _isAudioSent = true; // Set this to true when audio is sent

      showError('Audio file saved successfully!');
    } catch (e) {
      showError('Error saving audio file path: $e');
    }
  }
}
