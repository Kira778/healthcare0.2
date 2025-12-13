import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartHealthStaticApp());
}

class SmartHealthStaticApp extends StatelessWidget {
  const SmartHealthStaticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Health Emergency System (Static Demo)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const MainScreen(),
    );
  }
}
