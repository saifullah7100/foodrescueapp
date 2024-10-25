// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Auth/login.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/contactInfo.dart';
import 'package:foods_rescue/ui/availablefood/acceptFoodrequest.dart';
import 'package:foods_rescue/ui/need_request/NgoAcceptedNeed.dart';

class SettingsScreenReciver extends StatelessWidget {
  const SettingsScreenReciver({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title: Text('Settings',style: AppColor.bebasstylesubheading(),),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                auth.currentUser!.photoURL.toString(),
                style: AppColor.bebasstylesubheading(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Name :${auth.currentUser!.displayName.toString()}',
               style: AppColor.bebasstylesubheading(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle term and condition button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appbarColor
                ),
                child: Text('Term and Condition',style: AppColor.bebasstyle(
                ),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactInfoScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appbarColor
                ),
                child: Text('Contact Us',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FoodRequestPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appbarColor
                ),
                child:  Text('Accepted Available Food Requests',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NgoAcceptedNeedPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appbarColor
                ),
                child:  Text('My Food Need Requests',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreenfood()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.appbarColor
                ),
                child: Text('Logout',style: AppColor.bebasstyle(),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
