import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://172.20.10.2:5001";

  // 🔹 Signup
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // 🔹 Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // 🔹 Predict Disease — supports both ViT & EfficientNet
  static Future<Map<String, dynamic>> predict(
    File image,
    int userId, {
    String modelType = "vit", // 👈 default is ViT
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/predict"),
    );

    request.fields['user_id'] = userId.toString();
    request.fields['model_type'] = modelType; // 👈 tell backend which model to use
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  // 🔹 Get Scan History
  static Future<List<dynamic>> getHistory(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/history/$userId"));
    return jsonDecode(res.body);
  }
}
