import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foods_rescue/Auth/login.dart';
import 'package:foods_rescue/Map/map.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/authentication/login_screen_and_sign_up.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class SignUpScreenfood extends StatefulWidget {
  const SignUpScreenfood({super.key});

  @override
  _SignUpScreenfoodState createState() => _SignUpScreenfoodState();
}

class _SignUpScreenfoodState extends State<SignUpScreenfood> {
  bool _obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _selectedOption;
  Position? _currentPosition;
@override
  void initState() {
    _requestLocationPermission();
    super.initState();
  }

  Future<void> _convertLatLngToAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
       if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          locationController.text =
              locationName; // Set the human-readable address
        });
      }
    } catch (e) {
      print("Error converting lat/long to address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to convert lat/long to address: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<AuthProvider1>(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                  Icons.food_bank,
                  color: AppColor.primaryColor,
                  size: 150,
            ),
                ),
                const SizedBox(height: 10),
                 Text(
                  "Food Rescue",
                  style: AppColor.bebasstyle(),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration:  InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person,
                              color: AppColor.primaryColor,
                            ),
                            hintText: "Name",
                            hintStyle: AppColor.bebasstyle(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 11),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.category,
                              color: AppColor.primaryColor,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an option';
                            }
                            return null;
                          },
                          hint:  Text("Select Type",style: AppColor.bebasstyle(),),
                          items: <String>['Donor', 'Receiver']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,style: AppColor.bebasstyle(),),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 11),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:  InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email,
                              color: AppColor.primaryColor,
                            ),
                            hintText: "Email",
                            hintStyle: AppColor.bebasstyle(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 11,
                        ),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          decoration:  InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: AppColor.primaryColor,
                            ),
                            hintText: "Phone",
                            hintStyle: AppColor.bebasstyle(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Phone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 11),
                       TextFormField(
                          controller: locationController, // Use the controller
                          //readOnly: true, // Make it read-only
                          decoration:  InputDecoration(
                            prefixIcon: const Icon(
                              Icons.location_city_outlined,
                              color: AppColor.primaryColor,
                            ),
                            hintText: "Location",
                            hintStyle:  AppColor.bebasstyle(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Failed to get location'; // Validator message
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 11,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppColor.primaryColor,
                            ),
                            hintText: "Password",
                            hintStyle:  AppColor.bebasstyle(),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginScreenfood()));
                              },
                              child:  Text(
                                "Already Have an Account",
                                style: AppColor.bebasstyle(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: 350,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await registrationProvider.registerUser(
                                          emailController.text.toString(),
                                          nameController.text.toString(),
                                          _selectedOption,
                                          passwordController.text.toString(),
                                          phoneController.text.toString(),
                                          locationController.text,
                                          context);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    "Sign Up",
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
  Future<void> _getCurrentLocation() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
  await _convertLatLngToAddress(position);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
    }
  }

  Future<String> getPlaceName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        // Return a formatted address or place name
        Placemark place = placemarks.first;
        return "${place.locality},${place.street},${place.country}, ";
      }
    } catch (e) {
      print("Error getting place name: $e");
    }
    return "Unknown location"; // Fallback value
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is denied forever.')),
      );
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation(); // Retrieve the current location
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
    }
  }

  Future<void> _register(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Successfully registered
      print('User registered: ${userCredential.user}');
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully registered'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenfood()),
      );
    } catch (e) {
      // Handle registration errors
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
