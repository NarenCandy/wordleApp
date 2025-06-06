import 'package:flutter/material.dart';
import 'package:wordle/constants/colors.dart';

final ThemeData lighttheme = ThemeData(
    primaryColorLight: lightThemeLightShade,
    primaryColorDark: lightThemedarkShade,
    appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    textTheme: const TextTheme().copyWith(
        bodyMedium:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)));

final ThemeData darktheme = ThemeData(
    primaryColorDark: darkThemeDarkShade,
    primaryColorLight: darkThemeLightShade,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    scaffoldBackgroundColor: Colors.black,
    dividerColor: darkThemeLightShade,
    brightness: Brightness.dark,
    textTheme: const TextTheme().copyWith(
        bodyMedium:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)));
