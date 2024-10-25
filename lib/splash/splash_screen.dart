import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Auth/login.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/ui/doner/bottomNavBardonor.dart';
import 'package:foods_rescue/ui/reciver/bottomNavBarReciver.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key, required this.login,required this.isDarkMode,required this.toggleCallback});
  final bool login;
  bool isDarkMode;
  final VoidCallback toggleCallback;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () => _navigateToNextScreen(),
    );
  }
  void _navigateToNextScreen() {
    if (widget.login && _auth.currentUser != null) {
      // Check the user's role or status
      // For example, if the user is a donor, navigate to the donor screen
      // Otherwise, navigate to the receiver screen
      String? userRole = _auth
          .currentUser!.photoURL; // Assuming you're storing role in photoURL
      if (userRole == "Donor") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const BottomNavBardonor(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const bottomNavBarReciver(),
          ),
        );
      }
    } else {
      // If not logged in, navigate to the login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreenfood(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:Colors.transparent,
            actions: [
              Visibility(
                visible: false,
                child: IconButton(onPressed: widget.toggleCallback, 
                icon: Icon(
                widget.isDarkMode ?Icons.light_mode: Icons.dark_mode,
                )),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                  children: [
                    Text(
                            'Welcome',
                            style: AppColor.bebasstyleheading(),
                          ),
                          const SizedBox(height: 200,),
                    const Icon(Icons.food_bank,
                              size: 150,
                              color: AppColor.primaryColor,
                              ),
                              const SizedBox(height: 30,),
                    Text('Food Rescue',
                              style: AppColor.bebasstyleheading(),
                              ),
                    const SizedBox(height: 200,),
                    const CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                    ),
                  ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
