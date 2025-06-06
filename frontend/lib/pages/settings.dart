import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle/pages/loginpage.dart';
import 'package:wordle/providers/theme_provider.dart';
import 'package:wordle/utils/quick_box.dart';
import 'package:wordle/utils/theme_preferences.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.maybePop(context);
              },
              icon: const Icon(Icons.clear),
            )
          ],
        ),
        body: Column(
          children: [
            Consumer<ThemeProvider>(builder: (_, notifier, __) {
              bool _isSwitched = false;
              _isSwitched = notifier.isDark;

              return SwitchListTile(
                  title: Text("Dark Theme"),
                  value: _isSwitched,
                  onChanged: (value) {
                    _isSwitched = value;

                    ThemePreferences.saveTheme(isDark: _isSwitched);
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setTheme(turnOn: _isSwitched);
                  });
            }),
            ListTile(
              title: Text("Reset Statistics"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('stats');
                prefs.remove('chart');
                prefs.remove('row');
                runQuickBox(context: context, message: 'Statistics Reset');
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Loginpage()),
                    (route) => false);
              },
            )
          ],
        ));
  }
}
