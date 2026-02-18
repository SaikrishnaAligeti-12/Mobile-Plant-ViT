import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController(text: "20");
  final newPassController = TextEditingController();

  String selectedGender = "Male";
  bool showPassword = false;
  bool isLoading = false;

  static const String baseUrl = "http://192.168.70.161:5001";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final response = await http.get(Uri.parse("$baseUrl/profile/$userId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nameController.text = data['name'] ?? '';
          ageController.text = data['age']?.toString() ?? '20';
          selectedGender = data['gender'] ?? 'Male';
        });
      }
    }
  }

  Future<void> updateProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  if (userId == null) return;

  setState(() => isLoading = true);
  final response = await http.put(
    Uri.parse("$baseUrl/update_profile"), // ✅ FIXED — no /$userId
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id": userId, // ✅ send ID in body instead
      "name": nameController.text.trim(),
      "age": ageController.text.trim(),
      "gender": selectedGender,
    }),
  );
  setState(() => isLoading = false);

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile updated successfully")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to update profile (${response.body})")),
    );
  }
}



  Future<void> changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    final response = await http.put(
      Uri.parse("$baseUrl/change_password/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"new_password": newPassController.text.trim()}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔑 Password changed successfully")),
      );
      newPassController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to change password")),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageValue = double.tryParse(ageController.text) ?? 20;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Age Scroll Picker
            Row(
              children: [
                const Text("Age: ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: ageValue,
                    min: 5,
                    max: 100,
                    divisions: 95,
                    label: ageValue.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        ageController.text = value.toInt().toString();
                      });
                    },
                  ),
                ),
                Text(ageController.text),
              ],
            ),
            const SizedBox(height: 10),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Update Profile
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Profile"),
              ),
            ),
            const Divider(height: 40),

            // Password field with show toggle
            TextField(
              controller: newPassController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: "New Password",
                border: const OutlineInputBorder(),
                suffixIcon: Checkbox(
                  value: showPassword,
                  onChanged: (value) {
                    setState(() {
                      showPassword = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Change Password Button
            Center(
              child: ElevatedButton(
                onPressed: changePassword,
                child: const Text("Change Password"),
              ),
            ),
            const SizedBox(height: 30),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
