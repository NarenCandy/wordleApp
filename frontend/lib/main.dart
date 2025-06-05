import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle/pages/loginpage.dart';
import 'package:wordle/pages/registerpage.dart';

import 'package:wordle/providers/controller.dart';
import 'package:wordle/providers/theme_provider.dart';
import 'package:wordle/utils/theme_preferences.dart';
import 'package:wordle/constants/themes.dart';
import 'package:wordle/pages/homepage.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to load theme and token
  Future<Map<String, dynamic>> _getInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = await ThemePreferences.getTheme();
    final hasToken = prefs.getString('token') != null;
    return {
      'isDark': isDark,
      'hasToken': hasToken,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Controller(userId: '')),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: FutureBuilder(
        future: _getInitialSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final initialData = snapshot.data as Map<String, dynamic>;
          final isDark = initialData['isDark'] as bool;
          final hasToken = initialData['hasToken'] as bool;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ThemeProvider>(context, listen: false)
                .setTheme(turnOn: isDark);
          });

          return Consumer<ThemeProvider>(
            builder: (_, notifier, __) => MaterialApp(
              title: 'Wordle Clone',
              debugShowCheckedModeBanner: false,
              theme: notifier.isDark ? darktheme : lighttheme,
              home: hasToken ? const HomePage() : const RegisterPage(),
            ),
          );
        },
      ),
    );
  }
}
