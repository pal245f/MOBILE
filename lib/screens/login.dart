import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add ScreenUtil for responsiveness
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../context/user.model.dart';
import '../context/user.provider.dart';
import '../utils/routes.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _fullNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.token != null) {
        Navigator.pushReplacementNamed(context, AllRoutes.BottomNavRoute);
      }
    });
  }

  Future<void> login(String fullName, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 300));

    final nameParts = fullName.trim().split(' ');
    if (nameParts.length < 2) {
      _showErrorDialog(context, 'Ilagay ang buong pangalan.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final FirstName = nameParts.first;
    final LastName = nameParts.sublist(1).join(' ');

    final url = Uri.parse(
        'https://baybay-salita-heroku-8c328f3ddd0f.herokuapp.com/api/mobileLogin');
    final response = await http.post(
      url,
      body: {'FirstName': FirstName, 'LastName': LastName},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User(
        lrn: data['user']['LRN'],
        section: data['user']['Section'],
        firstName: data['user']['FirstName'],
        lastName: data['user']['LastName'],
      );
      final token = data['token'];

      print("Token: $token");

      Provider.of<UserProvider>(context, listen: false).setUser(user, token);

      // Show the success SnackBar after login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome, ${user.firstName}!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacementNamed(context, AllRoutes.BottomNavRoute);
    } else {
      _showErrorDialog(context, 'Walang pangalang naka rehistro');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.token != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AllRoutes.BottomNavRoute);
          });
          return Container();
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                decoration:  BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/img/login.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 25.h, // Adjusted using ScreenUtil for responsive height
                        left: 20.w, // Adjusted using ScreenUtil for responsive width
                        right: 20.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AllRoutes.BottomNavRoute);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 25.sp, // Adjusted for responsive icon size
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 250.h, // Adjusted for responsive height
                      width: 450.w, // Adjusted for responsive width
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("lib/img/logo1.png"))),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'LOGIN',
                              style: GoogleFonts.fredoka(
                                textStyle: TextStyle(
                                  fontSize: 35.sp, // Adjusted for responsive font size
                                  color: Color(0xfff5505b),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h), // Adjusted for responsive spacing
                            Text(
                              'Mag sign-in gamit ang iyong Account',
                              style: GoogleFonts.fredoka(
                                textStyle: TextStyle(
                                  fontSize: 15.sp, // Adjusted for responsive font size
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h), // Adjusted for responsive spacing
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50.w), // Adjusted for responsive padding
                              child: TextField(
                                controller: _fullNameController,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  labelText: 'Pangalan',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.sp, // Adjusted for responsive font size
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintText: 'Lagay ang iyong pangalan',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp, // Adjusted for responsive font size
                                  ),
                                  prefixIcon: Icon(
                                    Iconsax.user,
                                    color: Colors.black,
                                    size: 18.sp, // Adjusted for responsive icon size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r), // Adjusted for responsive border radius
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h), // Adjusted for responsive spacing
                            MaterialButton(
                              onPressed: () {
                                final fullName = _fullNameController.text;
                                if (fullName.isEmpty) {
                                  _showErrorDialog(context, 'Ilagay ang buong pangalan');
                                } else if (!_isLoading) {
                                  login(fullName, context);
                                }
                              },
                              color: Color(0xfff5505b),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 130.w), // Adjusted for responsive padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r), // Adjusted for responsive border radius
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color.fromRGBO(
                                              240, 236, 255, 1)),
                                    )
                                  : const Text(
                                      "Pumasok",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  runApp(ScreenUtilInit(
    designSize: Size(375, 812), // Set the design size for scaling
    builder: (context, child) => MaterialApp(
      home: LoginPage(),
    ),
  ));
}
