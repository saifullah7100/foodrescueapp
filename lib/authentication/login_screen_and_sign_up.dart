// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:foods_rescue/Auth/login.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
import 'package:foods_rescue/ui/doner/bottomNavBardonor.dart';
import 'package:foods_rescue/ui/reciver/bottomNavBarReciver.dart';

///provider
class AuthProvider1 extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoggedIn = true;
      notifyListeners();
      String? userRole = _auth
          .currentUser!.photoURL; // Assuming you're storing role in photoURL
      if (userRole == "Donor") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => BottomNavBardonor(),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => bottomNavBarReciver(),
          ),
        );
      }
      showCustomSnackbar(context, "Login Succesfully");
    } catch (e) {
      print('Login error: $e');

      showalertSnackbar(context, "Invalid email or password");
    }
  }

  AuthProvider1() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final user = _auth.currentUser;
    _isLoggedIn = user != null;
    notifyListeners();
  }

  ///sigUp
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> registerUser(String email, name, type, String password,
      String phone, String location, BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: deprecated_member_use
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.updatePhotoURL(type);

      User? user = userCredential.user;
      print(user);
      // await addUserToFirestore(user!);
      await _firestore.collection('users').doc(user!.uid).set({
        'email': user.email,
        'userId': user.uid,
        'userName': user.displayName,
        'userType': user.photoURL,
        'phone': phone, // Add phone number
        'location': location, // Add human-readable address
      });
      showCustomSnackbar(context, "Registration successful!");
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => LoginScreenfood()));
    } catch (e) {
      print('Registration error: $e');
      // Show an error Snackbar.

      showalertSnackbar(context, "Errors or Email Already Used.");
    }
  }

  Future<void> addUserToFirestore(User user) async {
    final String uid = user.uid;
    final CollectionReference usersCollection =
        _firestore.collection('users');
    await usersCollection.doc(uid).set({
      'email': user.email,
      'userId': user.uid,
      'userName': user.displayName,
      'usertype': user.photoURL,
    });
    }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _isLoggedIn = false;
      notifyListeners();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreenfood()));
      showCustomSnackbar(context, "User Sign Out");
    } catch (e) {
      print("Error logging out: $e");
    }
  }
  //auth provider end
}

///custom button
class MyButton extends StatelessWidget {
  final String text;
  final void Function()? ontap;
  const MyButton({super.key, required this.text, this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColor.primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
        child: Center(
            child: Text(
          text,
          style: AppColor.bebasstyle(),
        )),
      ),
    );
  }
}
