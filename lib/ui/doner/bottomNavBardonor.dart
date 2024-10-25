// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/ui/doner/AddFreeFood.dart';
import 'package:foods_rescue/ui/doner/HomePageDoner.dart';
import 'package:foods_rescue/ui/doner/settingsdonor.dart';
import 'package:foods_rescue/ui/home_screen.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:foods_rescue/upload.dart';
class BottomNavBardonor extends StatefulWidget {
  const BottomNavBardonor({super.key});

  @override
  _BottomNavBardonorState createState() => _BottomNavBardonorState();
}

class _BottomNavBardonorState extends State<BottomNavBardonor> {
  List<IconData> iconList = [
    Icons.home,
    Icons.food_bank,
    Icons.chat,
    Icons.settings,
  ];

  int page = 0;

  int pageView = 0;

  final PageController _pageController = PageController(initialPage: 0);

  Widget pageViewSection() {
    return PageView(
      controller: _pageController,
      onPageChanged: (value) {
        setState(() {
          page = value;
        });
      },
      children: const [
         HomePageDoner(),
         AddFreeFood(),
         HomeScreen(),
         SettingsScreendonor()
       
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, //icon background
      body: pageViewSection(),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: AppColor.primaryColor,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UploadPage(),
          ));
          // Navigate to upload page
        },
        child: const Icon(
          Icons.add,
          color: AppColor.subheadingColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: AppColor.appbarColor,
        gapLocation: GapLocation.center,
        //gapWidth: 50,
        activeColor: AppColor.primaryColor,
        inactiveColor: Colors.grey,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.smoothEdge,
        //notchMargin: 0,
        icons: iconList,
        activeIndex: page,
        onTap: (p0) {
          pageView = p0;
          _pageController.animateToPage(p0,
              curve: Curves.linear,
              duration: const Duration(milliseconds: 300));
        },
      ),
    );
  }
}