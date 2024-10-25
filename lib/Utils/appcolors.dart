import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColor {
  static const Color primaryColor = Color(0xFF009688); // Corrected comma to semicolon
  static const Color subheadingColor = Color(0xFFB2FFFC);
  static const Color appbarColor = Color(0xFF00796B);
  static TextStyle bebasstyle(){
    return GoogleFonts.roboto(
     fontSize: 16,
     fontWeight: FontWeight.w600,
     color: Colors.black87,
    );
  }
  static TextStyle bebasstyleheading(){
    return GoogleFonts.bebasNeue(
     fontSize: 25,
     color: const Color(0xFF1A237E),
     fontWeight: FontWeight.bold,
    );
  }
   static TextStyle bebasstylesubheading(){
    return GoogleFonts.bebasNeue(
     fontSize: 26,
     color: const Color(0xFFB2FFFC),
    );
  }
  // Add more color constants as needed
}

