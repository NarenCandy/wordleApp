import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle/components/grid.dart';
import 'package:wordle/components/keyboard_row.dart';
import 'package:wordle/components/stats_bos.dart';
import 'package:wordle/constants/words.dart';
import 'package:wordle/pages/settings.dart';
import 'package:wordle/providers/controller.dart';
import 'package:wordle/utils/quick_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _word;

  Future<void> loadUserIdAndName() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username') ?? '';
    if (userId != null) {
      final controller = Provider.of<Controller>(context, listen: false);
      controller.setUserId(userId);
      controller.setUsername(username);
    }
  }

  @override
  void initState() {
    final r = Random().nextInt(words.length);
    _word = words[r];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<Controller>(context, listen: false);
      controller.setCorrectWord(word: _word);
      loadUserIdAndName();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<Controller>(
          builder: (_, notifier, __) {
            return AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(notifier.username, style: const TextStyle(fontSize: 16)),
                  const Text("Wordle",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart_outlined),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => const StatsBox());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const Settings()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              elevation: 0,
            );
          },
        ),
      ),
      body: Consumer<Controller>(
        builder: (_, notifier, __) {
          if (notifier.notEnoughLetters) {
            runQuickBox(context: context, message: "Not Enough");
          }
          if (notifier.gameCompleted) {
            if (notifier.gameWon) {
              runQuickBox(
                  context: context,
                  message: notifier.currentRow == 6 ? "Phew" : "Splendid!");
            } else {
              runQuickBox(context: context, message: notifier.correctWord);
            }

            Future.delayed(const Duration(milliseconds: 4000), () {
              if (mounted) {
                showDialog(context: context, builder: (_) => const StatsBox());
              }
            });
          }

          return const Column(
            children: [
              Divider(thickness: 2, height: 1),
              Expanded(flex: 7, child: Grid()),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    KeyboardRow(min: 1, max: 10),
                    KeyboardRow(min: 11, max: 19),
                    KeyboardRow(min: 20, max: 29),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
