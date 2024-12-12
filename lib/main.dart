import 'package:flutter/material.dart';
import 'loginpage.dart'; // Make sure this is the correct path to your login page
import 'package:sophiered/SplashScreen.dart';

void main() {
  // Optionally add any initialization code here before running the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Sophie Red Hotel App', // Set a title for your app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define the primary color for your app
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IntroductionScreen(), // Set the initial screen of your app
      //home: LoginPage(), // Set the initial screen of your app
      // Optionally add routes if you have multiple pages
      routes: {
        '/login': (context) => IntroductionScreen(),
        // Add other routes here
      },
    );
  }
}
