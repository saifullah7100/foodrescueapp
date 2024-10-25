// ignore_for_file: prefer_const_constructors
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadNeedFood extends StatefulWidget {
  const UploadNeedFood({super.key});

  @override
  State<UploadNeedFood> createState() => _UploadNeedFoodState();
}

class _UploadNeedFoodState extends State<UploadNeedFood> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // New variable to track loading state
  Position? _currentPosition;
  @override
  void initState() {
    _requestLocationPermission();
    super.initState();
  }
  Future<void> _uploadData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Upload the data to Firestore
      await FirebaseFirestore.instance.collection('needfoods').add({
        'name': nameController.text,
        'title': titleController.text,
        'description': descriptionController.text,
        'location':locationController.text,
        'userid': _auth.currentUser?.uid,
        'useremail': _auth.currentUser?.email,
        'accepted': false,
      });

      // Clear the form and image
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data uploaded successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message if any field is invalid or if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields '),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
        backgroundColor: AppColor.primaryColor,
        title: Text('Need For Food',style: AppColor.bebasstylesubheading(),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  style: AppColor.bebasstyle(),
                  controller: nameController,
                  decoration: InputDecoration(
                    labelStyle: AppColor.bebasstyle(),
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(
                      Icons.person,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  style: AppColor.bebasstyle(),
                  controller: titleController,
                  decoration: InputDecoration(
                    labelStyle: AppColor.bebasstyle(),
                    labelText: 'Food Required Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(
                      Icons.title,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  style: AppColor.bebasstyle(),
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelStyle: AppColor.bebasstyle(),
                    labelText: 'Food Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(
                      Icons.description,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  style: AppColor.bebasstyle(),
                        controller: locationController, // Use the controller
                        //readOnly: true, // Make it read-only
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                            color: AppColor.primaryColor,
                          ),
                          hintText: "Location",
                          hintStyle: AppColor.bebasstyle(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Failed to get location'; // Validator message
                          }
                          return null;
                        },
                      ),
                SizedBox(
                  height: 10,
                ),
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
                              await _uploadData(context);
                              setState(() {
                                _isLoading = false; 
                                 {
                             Navigator.pop(context);
                        }// Stop loading
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // <-- Radius
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            // Show CircularProgressIndicator if loading
                            "Upload Need Food",
                           style:  AppColor.bebasstyle(),
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
        SnackBar(content: Text('Location permission is denied forever.')),
      );
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation(); // Retrieve the current location
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is required.')),
      );
    }
  }
}