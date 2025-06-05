import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordle/components/stats_chart.dart';
import 'package:wordle/components/stats_tile.dart';
import 'package:wordle/constants/answer_stages.dart';
import 'package:wordle/data/keys_map.dart';
import 'package:wordle/pages/homepage.dart';
import 'package:wordle/providers/controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatsBox extends StatelessWidget {
  const StatsBox({super.key});

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<Map<String, dynamic>?> fetchStats() async {
    final userId = await getUserId();
    if (userId == null) return null;

    //print('Fetching stats for userId: $userId');
    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$baseUrl/api/game/stats/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
        size.width * 0.08,
        size.height * 0.12,
        size.width * 0.08,
        size.width * 0.12,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: const Icon(Icons.clear_rounded),
            alignment: Alignment.centerRight,
          ),
          const Text(
            "STATISTICS",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load stats'));
                }

                final stats = snapshot.data ??
                    {
                      'played': 0,
                      'winPercentage': 0,
                      'currentStreak': 0,
                      'maxStreak': 0,
                    };

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatsTile(heading: "Played", value: stats['played']),
                    StatsTile(heading: "Win%", value: stats['winPercentage']),
                    StatsTile(
                        heading: "Current \nStreak",
                        value: stats['currentStreak']),
                    StatsTile(
                        heading: "Max \nStreak", value: stats['maxStreak']),
                  ],
                );
              },
            ),
          ),
          const Expanded(flex: 8, child: StatsChart()),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(10),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                keysMap.updateAll((key, value) => AnswerStage.notAnswered);
                Provider.of<Controller>(context, listen: false).resetGame();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: const Text(
                "Replay",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
