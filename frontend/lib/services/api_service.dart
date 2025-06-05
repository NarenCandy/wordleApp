import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = dotenv.env['api_service_url']!;

  static Future<bool> saveResult({
    required String userId,
    required bool won,
    required int guesses,
  }) async {
    final url = Uri.parse('$baseUrl/result/save');
    final body = jsonEncode({
      'userId': userId,
      'won': won,
      'guesses': guesses,
    });
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> fetchStats(String userId) async {
    final url = Uri.parse('$baseUrl/result/stats/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
