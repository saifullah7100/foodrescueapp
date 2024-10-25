// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:foods_rescue/Auth/ForgetPassword.dart';
import 'package:foods_rescue/Auth/SignUp.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/authentication/login_screen_and_sign_up.dart';
import 'package:foods_rescue/ui/doner/bottomNavBardonor.dart';
import 'package:provider/provider.dart';

class LoginScreenfood extends StatefulWidget {
  const LoginScreenfood({super.key});

  @override
  _LoginScreenfoodState createState() => _LoginScreenfoodState();
}

class _LoginScreenfoodState extends State<LoginScreenfood> {
  bool _obscureText = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // New variable to track loading state

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider1>(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                 Icons.food_bank,
                 color: AppColor.primaryColor,
                 size: 150,
            ),
                ),
                SizedBox(height: 10),
                Text(
                  "Food Rescue",
                  style: AppColor.bebasstyle(),
                ),
                SizedBox(height: 5),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Rescue excess foods, fight waste feed \nthose in need efficiently",
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
                            labelStyle: AppColor.bebasstyle(),
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
                        SizedBox(height: 11),
                        TextFormField(
                          controller: passwordController,
                         obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColor.primaryColor,
                            ),
                            labelStyle: AppColor.bebasstyle(),
                            hintText: "Password",
                            hintStyle:  AppColor.bebasstyle(),
                             suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColor.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPassword(),
                                ),
                              );
                            },
                              child: Text(
                                "Forget Password?",
                                style: AppColor.bebasstyle(),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreenfood(),
                              ),
                            );
                          },
                          child: Text(
                            "Create a new Account",
                            style: AppColor.bebasstyle(),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: 350,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    // Disable button when loading
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true; // Start loading
                                      });
                                      await authProvider.login(
                                        context,
                                        emailController.text.toString(),
                                        passwordController.text.toString(),
                                      );
      
                                      setState(() {
                                        _isLoading = false; // Stop loading
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15), // <-- Radius
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : Text(
                                    // Show CircularProgressIndicator if loading
                                    "Login",
                                    style: AppColor.bebasstyle(),
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
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Successfully logged in
      print('User logged in: ${userCredential.user}');
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged in'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to bottom navigation bar page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBardonor()),
      );
    } catch (e) {
      // Handle login errors
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
