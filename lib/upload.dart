// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  File? _imageFile;
  final imagePicker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // New variable to track loading state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void pickMyImage(ImageSource imageSource){
    imagePicker.pickImage(source: imageSource).then((pickedImage){
    setState(() {
      _imageFile= File(pickedImage!.path);
    });
    });
  }
  void showPickerDialogoue(BuildContext mycontext){
    showModalBottomSheet(context: mycontext, builder: (context){
       return Container(
        decoration: BoxDecoration(
          color: AppColor.appbarColor
        ),
        height: 300,
        child: Column(
          children: [
            SizedBox(height: 30,),
            Text('Choose Your Photo From',style: AppColor.bebasstylesubheading(),),
             SizedBox(height: 50,),
            Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                IconButton(onPressed: (){
              Navigator.pop(context);
              pickMyImage(ImageSource.camera);
            }, icon: Icon(Icons.camera_alt_rounded,size: 45,color: AppColor.subheadingColor,)),
            Text('Camera',style: AppColor.bebasstylesubheading(),),
              ],
            ),
            Column(
              children: [
                IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.photo_sharp,size: 45,color: AppColor.subheadingColor,)),
            Text('Gallery',style: AppColor.bebasstylesubheading(),),
              ],
            ),
          ],
        ),
          ],
        ),
       );
    });
  }
  Future<void> _uploadData(BuildContext context) async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      // Generate a random number to append to the image URL
      final randomNumber = Random().nextInt(1000);

      // Upload the image to Firebase Storage
      final imageName = '$randomNumber.png';
      final imageRef =
          FirebaseStorage.instance.ref().child('images/$imageName');
      await imageRef.putFile(_imageFile!);

      // Get the download URL for the uploaded image
      final imageUrl = await imageRef.getDownloadURL();

      // Upload the data to Firestore
      await FirebaseFirestore.instance.collection('foods').add({
        'name': nameController.text,
        'title': titleController.text,
        'description': descriptionController.text,
        'pickupTime': pickupTimeController.text,
        'phone': phoneController.text.trim(),
        'location': locationController.text,
        'imageUrl': imageUrl,
        'userid': _auth.currentUser?.uid,
        'useremail': _auth.currentUser?.email,
        'accepted': false,
      });

      // Clear the form and image
      _formKey.currentState!.reset();
      setState(() {
        _imageFile = null;
      });

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
          content: Text('Please fill all fields and select an image.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
////////////
  ///

  Future<void> _getCurrentLocation() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Step 3: Convert LatLng to Address
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
        return "${place.locality}, ${place.country}";
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
          backgroundColor: AppColor.appbarColor,
          title: Text('Add Free Food',style: AppColor.bebasstylesubheading(),),
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
                  GestureDetector(
                    onTap:(){
                      showPickerDialogoue(context);
                    },
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: AppColor.primaryColor,
                      child: _imageFile == null
                          ? Center(
                              child: Text(
                                "Add Food Image",
                                style: AppColor.bebasstylesubheading(),
                              ),
                            )
                          : CircleAvatar(
                              radius: 100,
                              backgroundImage: FileImage(_imageFile!),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: AppColor.bebasstyle(),
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      labelStyle: AppColor.bebasstyle(),
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
                      labelText: 'Title',
                      labelStyle: AppColor.bebasstyle(),
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
                      labelText: 'Description',
                      labelStyle: AppColor.bebasstyle(),
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
                  SizedBox(height: 10),
                  TextFormField(
                    style: AppColor.bebasstyle(),
                    controller: pickupTimeController,
                    decoration: InputDecoration(
                      labelStyle: AppColor.bebasstyle(),
                      labelText: 'Pickup Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: AppColor.bebasstyle(),
                    controller: locationController, // Use the controller
                    readOnly: false, // Make it read-only
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
                                await _uploadData(context);
                                setState(() {
                                  _isLoading = false; // Stop loading
                                  {
                                Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadPage(),
                              ),
                            );
                          }
                                }  
                                );
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
                              "Upload Available Food",
                              style: AppColor.bebasstyle(),
                            ),
      
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
