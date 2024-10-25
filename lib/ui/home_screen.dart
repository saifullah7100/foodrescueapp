import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/authentication/login_screen_and_sign_up.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthProvider1 authProvider = AuthProvider1();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title:  Text(
            'Chat',
            style: AppColor.bebasstylesubheading(),
          ),
          actions: [
            IconButton(
              onPressed: () {
                authProvider.signOut(context);
              },
              icon: const Icon(
                Icons.logout_sharp,
                color: AppColor.subheadingColor,
              ),
            )
          ],
        ),
        body: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            ));
          }
          return ListView(
              children: snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItem(doc))
                  .toList());
        });
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            color: AppColor.appbarColor,
            child: ListTile(
              title: Text(
                data['email'],
                style: AppColor.bebasstyle(),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                              receiverUserEmail: data['email'],
                              receiverUserId: data['userId'],
                            )));
                print("Email: ${data['email']}, UserId: ${data['userId']}");
              },
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
