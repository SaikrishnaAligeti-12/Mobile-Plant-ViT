import 'package:flutter/material.dart';
import 'package:plant_disease_app/screens/login_screen.dart';
import 'package:plant_disease_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure widgets and async calls work before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Check if a user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  // Pass loggedIn to MyApp
  runApp(MyApp(loggedIn: userId != null));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      // ✅ Use named routes
      initialRoute: loggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
