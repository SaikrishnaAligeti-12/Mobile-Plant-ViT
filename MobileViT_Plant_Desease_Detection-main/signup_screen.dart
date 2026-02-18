import 'package:flutter/material.dart';
import 'package:plant_disease_app/services/api_service.dart';
import 'login_screen.dart'; // ⬅️ Make sure this import path matches your app’s structure

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final data = {
    'username': '',
    'email': '',
    'password': '',
    'name': '',
    'age': '',
    'gender': ''
  };
  bool loading = false;
  bool showPassword = false;
  int _age = 18;
  String? _gender;

  Future<void> signup() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    data['age'] = _age.toString();
    data['gender'] = _gender ?? '';

    setState(() => loading = true);
    final res = await ApiService.signup(data);
    setState(() => loading = false);

    final message = res['message'] ?? res['error'] ?? 'Error';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (res['message'] != null && res['message'].toString().toLowerCase().contains('success')) {
      // Wait a moment, then go to login
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                onSaved: (v) => data['username'] = v ?? '',
                validator: (v) => v!.isEmpty ? "Enter username" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                onSaved: (v) => data['email'] = v ?? '',
                validator: (v) => v!.isEmpty ? "Enter email" : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
                obscureText: !showPassword,
                onSaved: (v) => data['password'] = v ?? '',
                validator: (v) => v!.isEmpty ? "Enter password" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (v) => data['name'] = v ?? '',
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 15),

              // 🔽 Gender dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Gender"),
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _gender = val),
                validator: (v) => v == null ? "Select gender" : null,
              ),

              const SizedBox(height: 15),

              // 🔢 Age scroll (Slider)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Age", style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _age.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 90,
                    label: "$_age",
                    onChanged: (val) => setState(() => _age = val.round()),
                  ),
                  Center(child: Text("Selected Age: $_age")),
                ],
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: loading ? null : signup,
                child: loading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
