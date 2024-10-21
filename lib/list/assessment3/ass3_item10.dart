import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:trial_mobile/context/user.provider.dart';
import 'package:trial_mobile/screens/result_screen2.dart';
// ignore: unused_import
import 'package:trial_mobile/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Assess3Item10 extends StatefulWidget {
  final String activityCode;

  Assess3Item10({Key? key, required this.activityCode}) : super(key: key);

  @override
  _Assess3Item10State createState() => _Assess3Item10State();
}

class _Assess3Item10State extends State<Assess3Item10> {
  late FlutterSoundRecorder _recordingSession;
  late String _pathToAudio;
  bool _isRecording = false;
  bool _isRecordingComplete = false;
  bool _isAudioSent = false;
  bool _isLoading = false;
  late String _itemcode;
  String? _imageUrl;
  String typeValue = "";
  String _activityCode = '';
  String? _getword;

  String userInputId = "";

  @override
  void initState() {
    super.initState();
    initialize();
    fetchActivityData();
  }

  Future<void> clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('User1');
    await prefs.remove('User2');
    await prefs.remove('User3');
    await prefs.remove('User4');
    await prefs.remove('User5');
    await prefs.remove('User6');
    await prefs.remove('User7');
    await prefs.remove('User8');
    await prefs.remove('User9');
    await prefs.remove('User10');
  }

  @override
  void dispose() {
    _recordingSession.closeAudioSession();
    super.dispose();
  }

  Future<void> initialize() async {
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

    Directory directory = await getApplicationDocumentsDirectory();
    _pathToAudio = path.join(directory.path, 'temp_${widget.activityCode}.wav');
  }

  Future<void> fetchActivityData() async {
    final url =
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/getActivity/${widget.activityCode}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          final itemCode = data['Items'] as List<dynamic>;
          _itemcode = itemCode.isNotEmpty ? itemCode[9]['ItemCode'] : 'No Code';

          final word = data['Items'] as List<dynamic>;
          _getword = word.isNotEmpty ? itemCode[9]['Word'] : 'No Word';

          final items = data['Items'] as List<dynamic>;
          _imageUrl = items.isNotEmpty
              ? items[9]['Image']
              : 'https://via.placeholder.com/150';
          typeValue = data['Type'] ?? 'No Type available';
          _activityCode = '${widget.activityCode}';
          print('Type: $typeValue');
        });
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
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Pagsasanay 3',
          style: GoogleFonts.fredoka(
            textStyle: TextStyle(
                fontSize: 25.sp, color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
               height: 500.h,
              width: 370.w,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF004380)),
                      borderRadius: BorderRadius.circular(20.sp),
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
                        padding: EdgeInsets.all(10.w),
                        child: Text(
                          'Basahin ng wasto ang salita:',
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
                      Text(
                        '${_getword ?? ' No Word'}',
                        style: GoogleFonts.fredoka(
                          textStyle: TextStyle(
                            fontSize: 25.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                   width: 250.w,
                    height: 300.h,
                        child: _imageUrl != null
                            ? (_imageUrl!.endsWith('.svg')
                                ? SvgPicture.network(_imageUrl!,
                                    fit: BoxFit.cover)
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
                      SizedBox(height: 20.h),
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
                            _isLoading
                                ? CircularProgressIndicator()
                                : _buildElevatedButton(
                                    icon: Icons.send_rounded,
                                    iconColor: Colors.white,
                                    label: 'Ipasa',
                                    onPressFunc: () => sendAudio(userProvider),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen2(
                            activityCode: widget.activityCode,
                            userInputId: userInputId,
                          ),
                        ),
                      );
                    } else {
                      showError(
                          'Pakilagay ang pinagtalang salita bago sumunod.');
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
                      textStyle: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          path.join(directory.path, 'temp_${widget.activityCode}_item10.wav');

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
      _isRecordingComplete = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('User10', _pathToAudio);
  }

  Future<void> sendAudio(UserProvider userProvider) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String lrn = userProvider.user?.lrn ?? '';

    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      String? audioFilePath1 = prefs.getString('User1');
      String? audioFilePath2 = prefs.getString('User2');
      String? audioFilePath3 = prefs.getString('User3');
      String? audioFilePath4 = prefs.getString('User4');
      String? audioFilePath5 = prefs.getString('User5');
      String? audioFilePath6 = prefs.getString('User6');
      String? audioFilePath7 = prefs.getString('User7');
      String? audioFilePath8 = prefs.getString('User8');
      String? audioFilePath9 = prefs.getString('User9');
      String? audioFilePath10 = prefs.getString('User10');
      String? item1 = prefs.getString('ItemCode1');
      String? item2 = prefs.getString('ItemCode2');
      String? item3 = prefs.getString('ItemCode3');
      String? item4 = prefs.getString('ItemCode4');
      String? item5 = prefs.getString('ItemCode5');
      String? item6 = prefs.getString('ItemCode6');
      String? item7 = prefs.getString('ItemCode7');
      String? item8 = prefs.getString('ItemCode8');
      String? item9 = prefs.getString('ItemCode9');

      // Debugging audio file paths
      print('audioFilePath1: $audioFilePath1');
      print('audioFilePath2: $audioFilePath2');
      print('audioFilePath3: $audioFilePath3');
      print('audioFilePath4: $audioFilePath4');
      print('audioFilePath5: $audioFilePath5');
      print('audioFilePath6: $audioFilePath6');
      print('audioFilePath7: $audioFilePath7');
      print('audioFilePath8: $audioFilePath8');
      print('audioFilePath9: $audioFilePath9');
      print('Current audio path: $audioFilePath10');

      // Check if the audio files exist
      if (audioFilePath10 == null || !File(audioFilePath10).existsSync()) {
        showError('File does not exist at path: $audioFilePath10');
        return;
      }

      // Check if there is an audio file to upload
      if (_pathToAudio.isEmpty || !File(_pathToAudio).existsSync()) {
        showError('No audio file to upload.');
        return;
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/userInput'),
      )
        ..fields['ActivityCode'] = _activityCode
        ..fields['Itemcode1'] = item1 ?? ''
        ..fields['Itemcode2'] = item2 ?? ''
        ..fields['Itemcode3'] = item3 ?? ''
        ..fields['Itemcode4'] = item4 ?? ''
        ..fields['Itemcode5'] = item5 ?? ''
        ..fields['Itemcode6'] = item6 ?? ''
        ..fields['Itemcode7'] = item7 ?? ''
        ..fields['Itemcode8'] = item8 ?? ''
        ..fields['Itemcode9'] = item9 ?? ''
        ..fields['Itemcode10'] = _itemcode
        ..fields['LRN'] = userProvider.user?.lrn ?? ''
        ..fields['Section'] = userProvider.user?.section ?? ''
        ..fields['Type'] = typeValue;

      request.files.add(await http.MultipartFile.fromPath(
        'User1',
        audioFilePath1!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User2',
        audioFilePath2!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User3',
        audioFilePath3!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User4',
        audioFilePath4!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User5',
        audioFilePath5!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User6',
        audioFilePath6!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User7',
        audioFilePath7!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User8',
        audioFilePath8!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User9',
        audioFilePath9!,
        contentType: MediaType('audio', 'wav'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'User10',
        audioFilePath10,
        contentType: MediaType('audio', 'wav'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        await prefs.setBool('${widget.activityCode}_$lrn', true);
        print("Activity ${widget.activityCode} is marked as completed.");

        final responseBody = await response.stream.bytesToString();
        final jsonData = json.decode(responseBody);

        if (jsonData.containsKey('UserInputId') &&
            jsonData['UserInputId'] != null) {
          userInputId = jsonData['UserInputId'];
        } else {
          showError('UserInputId not found in response.');
          return;
        }

        setState(() {
          _isAudioSent = true;
        });
        showError('Audio uploaded successfully!');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen2(
              activityCode: widget.activityCode,
              userInputId: userInputId,
            ),
          ),
        );

        await clearLocalStorage();
      } else {
        final responseBody = await response.stream.bytesToString();
        showError(
            'Failed to upload audio. Status code: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      showError('Error uploading audio: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
