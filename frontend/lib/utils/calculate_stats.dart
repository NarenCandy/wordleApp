import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Send new game result to backend

final baseUrl = dotenv.env['API_URL'];
Future<bool> calculateStats({
  required bool gameWon,
  required int guesses,
}) async {
  final userId = await _getUserId();
  if (userId == null) {
    print('UserId not found, cannot save stats.');
    return false;
  }

  final url = Uri.parse('$baseUrl/api/game/save');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'won': gameWon,
      'guesses': guesses,
    }),
  );

  return response.statusCode == 201;
}

/// Fetch stats from backend for the current user
Future<Map<String, dynamic>?> getStats() async {
  final userId = await _getUserId();
  if (userId == null) {
    print('UserId not found, cannot fetch stats.');
    return null;
  }

  final url = Uri.parse('$baseUrl/api/result/stats/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Failed to fetch stats from backend: ${response.statusCode}');
    return null;
  }
}

/// Helper to get userId from SharedPreferences
Future<String?> _getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}
