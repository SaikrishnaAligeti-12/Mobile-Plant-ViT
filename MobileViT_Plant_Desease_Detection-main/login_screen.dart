import 'package:flutter/material.dart';
import 'package:plant_disease_app/screens/signup_screen.dart';
import 'package:plant_disease_app/screens/home_screen.dart';
import 'package:plant_disease_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true; // 👁️ controls password visibility

  Future<void> login() async {
  setState(() => loading = true);
  final res = await ApiService.login(emailController.text, passwordController.text);
  setState(() => loading = false);

  if (res['message'] == 'Login successful') {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', res['user_id']);
    await prefs.setString('username', res['username']);
    await prefs.setString('name', res['name'] ?? ''); // ✅ Added line

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['error'] ?? 'Login failed')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🌿 Plant Disease Detector",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // toggle visibility
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              ),
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
