import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trial_mobile/context/user.provider.dart';

import '../utils/routes.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
              IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushNamed(context, AllRoutes.BottomNavRoute);
          },
        ),
            Text(
              'Profile',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                textStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/img/categ.png'), fit: BoxFit.cover)),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 90,
            ),
            Container(
              height: 395,
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(fit: StackFit.expand, children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                          ),
                          Text(
                            '${user?.firstName ?? 'First Name'} ${user?.lastName ?? 'Last Name'}',
                            style: GoogleFonts.fredoka(
                              textStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            user?.lrn ?? 'Unknown ID',
                            style: GoogleFonts.fredoka(
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withOpacity(.3),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Grade',
                                    style: GoogleFonts.fredoka(
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '1',
                                    style: GoogleFonts.fredoka(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 38),
                                child: Container(
                                  height: 40,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Section',
                                    style: GoogleFonts.fredoka(
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    user?.section ?? 'Unknown Section',
                                    style: GoogleFonts.fredoka(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                AssetImage('lib/img/letters/student.jpg'),
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xfff5505b).withOpacity(.5),
                                width: 5.0,
                              ))),
                    ),
                  ),
                ]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
