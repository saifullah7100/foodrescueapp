// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Auth/login.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/contactInfo.dart';
import 'package:foods_rescue/ui/availablefood/DonerFoodRequest.dart';
import 'package:foods_rescue/ui/need_request/acceptFoodneed.dart';

class SettingsScreendonor extends StatelessWidget {
  const SettingsScreendonor({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title: Text('Settings Donor',style: AppColor.bebasstylesubheading(),),
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
                style: TextButton.styleFrom(
                              backgroundColor: AppColor.appbarColor,
                            ),
                onPressed: () {
                  // Handle term and condition button press
                },
                child: Text('Term and Condition',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: TextButton.styleFrom(
                              backgroundColor: AppColor.appbarColor,
                            ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactInfoScreen()),
                  );
                },
                child: Text('Contact Us',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: TextButton.styleFrom(
                              backgroundColor: AppColor.appbarColor,
                            ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DonerRequestPage()));
                },
                child:  Text('My Food Available Request',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: TextButton.styleFrom(
                              backgroundColor: AppColor.appbarColor,
                            ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => acceptFoodneedPage()));
                },
                child: Text('Accepted Need Food Request',style: AppColor.bebasstyle(),),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: TextButton.styleFrom(
                              backgroundColor: AppColor.appbarColor,
                            ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreenfood()));
                },
                child: Text('Logout',style: AppColor.bebasstyle(),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
