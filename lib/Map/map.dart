import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _selectedLocation = const LatLng(33.712833272430125, 73.02835501997849);

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onConfirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title:  Text('Select Location',style: AppColor.bebasstyle(),),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _onConfirmLocation,
            ),
          ],
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _selectedLocation,
            zoom: 14.0,
          ),
          onTap: _onMapTapped,
          markers: {
            Marker(
              markerId: const MarkerId('selected-location'),
              position: _selectedLocation,
            ),
          },
        ),
      ),
    );
  }
}
