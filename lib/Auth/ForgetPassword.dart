// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foods_rescue/Utils/appcolors.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a success message or navigate to another screen
      print("Password reset email sent successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent successfully'),
      ));
    } catch (e) {
      // Handle errors such as invalid email, user not found, etc.
      print("Error sending password reset email: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending password reset email: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              Icon(
              Icons.food_bank,
              color: AppColor.primaryColor,
              size: 150,
            ),
              Text(
                "Forget Password",
                style: AppColor.bebasstyle(),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Please Enter your Email to forget the password",
                    textAlign: TextAlign.center,
                    style: AppColor.bebasstyle(),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: AppColor.primaryColor,
                          ),
                          hintText: "Email",
                          hintStyle: AppColor.bebasstyle(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            String email = emailController.text.trim();
                            await resetPassword(email);
                          }
                        },
                        child: Container(
                          height: 54,
                          width: 324,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: AppColor.bebasstyle(),
                            ),
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
      ),
    );
  }
}
