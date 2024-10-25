// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/ui/home_screen.dart';
import 'package:foods_rescue/ui/reciver/HomePagereciver.dart';
import 'package:foods_rescue/ui/reciver/needfood.dart';
import 'package:foods_rescue/ui/reciver/settingsreciver.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:foods_rescue/uploadNeedFood.dart';

class bottomNavBarReciver extends StatefulWidget {
  const bottomNavBarReciver({super.key});

  @override
  _bottomNavBarReciverState createState() => _bottomNavBarReciverState();
}

class _bottomNavBarReciverState extends State<bottomNavBarReciver> {
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
         HomePagereciver(),
         NeedFood(),
         HomeScreen(),
         SettingsScreenReciver()
       
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              builder: (context) => UploadNeedFood(),
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
      ),
    );
  }
}