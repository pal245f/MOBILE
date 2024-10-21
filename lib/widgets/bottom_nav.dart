import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_mobile/screens/category.dart';
import 'package:trial_mobile/screens/profile.dart';
import 'package:trial_mobile/context/user.provider.dart';
import 'package:trial_mobile/utils/routes.dart';
import '../screens/pagsasanay_dashboard.dart';

class BottomNav extends StatefulWidget {
  BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _navigateBottomNavBar(int index) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isLoggedIn = userProvider.token != null;

    if (!isLoggedIn) {
      // Redirect to login page if the user is not logged in
      Navigator.pushReplacementNamed(context, AllRoutes.loginRoute);
      return;
    }

    if (_selectedIndex == index) {
      // Avoid unnecessary rebuilds if the selected index is the same
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _children = [
    CategoryPage(),          // Assuming CategoryPage is the home screen
    PagsasanayDashPage(),         // Assuming DashboardPage is the category screen
    ProfilePage(),           // Assuming ProfilePage is the profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _children,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          backgroundBlendMode: BlendMode.clear,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.085,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            elevation: 5,
            fixedColor: Color(0xfff5505b),
            currentIndex: _selectedIndex,
            onTap: _navigateBottomNavBar,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'Pagsasanay'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ]
          )     
        )
      )
    );
  }

  }
  


