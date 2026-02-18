import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_disease_app/screens/scan_screen.dart';
import 'package:plant_disease_app/screens/history_screen.dart';
import 'package:plant_disease_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => name = prefs.getString('name') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $name 🌱"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Model 1 (ViT)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(modelType: "model1"),
                ),
              ),
              child: const Text("Scan using Moblie Plant ViT Model"),
            ),

            const SizedBox(height: 16),

            // ✅ Model 2 (EfficientNetV2)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(modelType: "model2"),
                ),
              ),
              child: const Text("Scan using EfficientNetV2 Model"),
            ),

            const SizedBox(height: 16),

            // 🧾 History
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              child: const Text("View Scan History"),
            ),
          ],
        ),
      ),
    );
  }
}
